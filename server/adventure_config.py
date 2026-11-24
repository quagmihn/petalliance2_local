"""Resolve the authored floor cells for an Adventure ID."""
from collections import defaultdict
from functools import cache

from client_config import table


@cache
def _by_adventure():
    groups = defaultdict(list)
    for cell in table("SceneInfo").values():
        groups[cell["number"]].append(cell)
    return {key: tuple(sorted(cells, key=lambda cell: (cell["floor"], cell["id"])))
            for key, cells in groups.items()}


@cache
def scene_cells(adventure_id):
    adventure = table("AdventureInfo").get(adventure_id)
    if adventure is None or len(adventure["floorsizes"]) != adventure["floor"]:
        return ()
    cells = _by_adventure().get(adventure_id, ())
    # AdventureInfo.scene is read into fieldType in the Lua renderer.
    # SceneInfo.number is the Adventure ID and owns each cell and event.
    expected = {
        (floor, row, col)
        for floor, size in enumerate(adventure["floorsizes"], 1)
        for row in range(1, size["item"][1] + 1)
        for col in range(1, size["item"][0] + 1)
    }
    coords = {(cell["floor"], cell["eventX"], cell["eventY"]) for cell in cells}
    return cells if coords == expected and len(coords) == len(cells) else ()


def scene_encounter(adventure_id, scene_id, event_type):
    """Resolve authored battles, including the client's disposable overlay."""
    scene = next((cell for cell in scene_cells(adventure_id) if cell["id"] == scene_id), None)
    if scene is None:
        return None
    if scene["eventType"] == event_type:
        return int(scene["event"]), None
    if scene["eventType"] == 21:  # LtEventOption.EVENT_DISPOSABLE
        disposable = table("DisposableInfo").get(scene["event"])
        if disposable and disposable["eventType"] == event_type:
            # SearchingMapMgr passes this field directly to the event renderer.
            return int(disposable["eventRandomID"]), int(scene["event"])
    return None
