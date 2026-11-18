#!/usr/bin/env python3
"""Make the capture-shop confirmation amount track MarketInfo 201."""
from __future__ import annotations
import sqlite3
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'server'))
from client_config import table

PRICE=int(table('MarketInfo')[201]['num'])
assert PRICE > 0
LUA=ROOT/'decoded_lua/assets/src/GameMgr/Battle/BattleCCSB.lua'
text=LUA.read_text()
assert 'ItemInfo.getMarketInfoById(201)' in text and 'createStringWithFormat({"advtips9", tostring(price)})' in text
translations={
 'lang_en.db':('Confirm spending 100 ','Confirm spending <1> '),
 'lang_vn.db':('Xác nhận tốn 100','Xác nhận tốn <1>'),
 'lang_tw.db':('是否花費100','是否花費<1>'),
 'lang.db':('是否花费100','是否花费<1>'),
 'lang_id.db':('Gunakan  100','Gunakan  <1>'),
 'lang_th.db':('ต้องการใช้ 100','ต้องการใช้ <1>'),
}
for filename,(old,new) in translations.items():
    path=ROOT/'apk_extracted/assets/res/Config/db'/filename
    conn=sqlite3.connect(path)
    row=conn.execute("SELECT lang FROM tbl_lang WHERE code='advtips9'").fetchone()
    if row is None: raise SystemExit(f'{filename}: missing advtips9')
    source=row[0]
    if new in source:
        conn.close(); continue
    if source.count(old)!=1:
        conn.close(); raise SystemExit(f'{filename}: expected one source phrase, found {source!r}')
    updated=source.replace(old,new,1)
    conn.execute("UPDATE tbl_lang SET lang=? WHERE code='advtips9'",(updated,))
    conn.commit()
    if conn.execute('PRAGMA integrity_check').fetchone()[0] != 'ok':
        conn.close(); raise SystemExit(f'{filename}: SQLite integrity check failed')
    conn.close()
print(f'capture market 201 confirmation now formats configured price: {PRICE}; updated {len(translations)} locale databases')
