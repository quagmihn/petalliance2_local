"""Reader for the client's NewQuestInfo.dat (XDatReader row encoding)."""
from __future__ import annotations

import os
import struct
from dataclasses import dataclass, replace
from pathlib import Path


GACHA_GUIDE_QUEST_ID = 10010
FORMATION_GUIDE_QUEST_ID = 10011
# Dialogue 29 and 30 name Panda. GameGuideMgr3.firstSkillPromote looks up
# pokeID 45, the Grade A template in PokemonInfo and the localized catalog.
GACHA_GUIDE_PET_ID = 45


class QuestConfigError(ValueError):
    pass


@dataclass(frozen=True)
class Objective:
    event_type: int
    main_id: int
    sub_id: int
    final_id: int
    num_type: int
    amount: int
    query_type: int


@dataclass(frozen=True)
class Quest:
    quest_id: int
    name: str
    quest_type: int
    parent_id: int
    child_ids: tuple[int, ...]
    reset_type: int
    reset_period: int
    award_id: int
    objectives: tuple[Objective, ...]
    strong_type: str
    gold_reward: str
    exp_reward: str
    diamond_reward: int
    daily_power: int
    unlock_map_id: str
    need_visible: int
    first_pokemon_id: int
    client_commit_marker: bool = False


class _Row:
    def __init__(self, data: bytes):
        self.data, self.pos = data, 0

    def read(self, n: int) -> bytes:
        if n < 0 or self.pos + n > len(self.data):
            raise QuestConfigError("truncated NewQuestInfo row")
        value = self.data[self.pos:self.pos+n]
        self.pos += n
        return value

    def u8(self) -> int: return self.read(1)[0]
    def u16(self) -> int: return struct.unpack("<H", self.read(2))[0]
    def u32(self) -> int: return struct.unpack("<I", self.read(4))[0]

    def string(self) -> str:
        end = self.data.find(b"\0", self.pos)
        if end < 0:
            raise QuestConfigError("unterminated NewQuestInfo string")
        value = self.data[self.pos:end].decode("utf-8")
        self.pos = end + 1
        return value

    def vector(self, parse):
        return tuple(parse() for _ in range(self.u8()))

    def parse(self) -> Quest:
        quest_id, name, quest_type, parent_id = self.u32(), self.string(), self.u8(), self.u32()
        children = self.vector(self.u32)
        self.string(); self.string()  # start/end time
        reset_type, reset_period, award_id = self.u8(), self.u16(), self.u32()
        self.string(); self.string(); self.string()  # icon, desc, objective desc
        objectives = self.vector(lambda: Objective(
            self.u16(), self.u32(), self.u32(), self.u32(), self.u8(), self.u32(), self.u8()))
        strong_type, gold, exp = self.string(), self.string(), self.string()
        diamond, daily_power = self.u32(), self.u32()
        self.string()  # award icon
        unlock_map, visible, first_pokemon = self.string(), self.u32(), self.u32()
        if self.pos != len(self.data):
            raise QuestConfigError(f"NewQuestInfo row {quest_id} has {len(self.data)-self.pos} trailing bytes")
        return Quest(quest_id, name, quest_type, parent_id, children, reset_type,
                     reset_period, award_id, objectives, strong_type, gold, exp,
                     diamond, daily_power, unlock_map, visible, first_pokemon)


def load_quests(path: Path | None = None) -> dict[int, Quest]:
    if path is None:
        configured = os.getenv("NEW_QUEST_INFO_PATH")
        path = Path(configured) if configured else Path(__file__).resolve().parents[1] / "apk_extracted/assets/res/Config/NewQuestInfo.dat"
    raw = path.read_bytes()
    if len(raw) < 4:
        raise QuestConfigError("NewQuestInfo.dat header is truncated")
    count, offset, quests = struct.unpack_from("<I", raw, 0)[0], 4, {}
    for _ in range(count):
        if offset + 4 > len(raw):
            raise QuestConfigError("NewQuestInfo.dat row length is truncated")
        size = struct.unpack_from("<I", raw, offset)[0]
        offset += 4
        end = offset + size
        if end > len(raw):
            raise QuestConfigError("NewQuestInfo.dat row exceeds file")
        row = _Row(raw[offset:end]).parse()
        if row.quest_id in quests:
            raise QuestConfigError(f"duplicate quest ID {row.quest_id}")
        quests[row.quest_id] = row
        offset = end
    if offset != len(raw):
        raise QuestConfigError(f"NewQuestInfo.dat has {len(raw)-offset} trailing bytes")
    for quest in quests.values():
        # Zero is used as a padding/sentinel value in some table rows.
        missing = [child for child in quest.child_ids if child and child not in quests]
        if missing:
            raise QuestConfigError(f"quest {quest.quest_id} references missing children {missing}")
    # A small number of tutorial guide rows use a zero-target objective as a
    # client-side walkthrough marker. Keep this protocol meaning in explicit
    # data, rather than treating every zero-target objective as complete.
    marker_path = Path(__file__).resolve().parent / "config/quest_client_commit_markers.json"
    if marker_path.exists():
        import json
        marker_ids = {int(value) for value in json.loads(marker_path.read_text())}
        quests = {qid: (replace(q, client_commit_marker=True)
                        if qid in marker_ids else q) for qid, q in quests.items()}
    return quests
