# Start Monster2

Run `./server/run_all.sh` from the project root, or invoke the launcher by
absolute path. It defaults to `monster2_db` as role `monster2`, using the
system PostgreSQL Unix socket in `/run/postgresql`. Start Waydroid before
connecting the Android client.

Hosts with different PostgreSQL connection settings can set DATABASE_URL in
`server/.env.production`. Use Bash assignments and mode 0600. The file is
ignored by Git. Local PostgreSQL authentication can supply credentials
without storing them in the launcher.

The default ports are HTTP 8080 and TCP 5568. Ctrl+C shuts down both children.
Run `./server/run_all.sh test` with an explicit DATABASE_URL for
`monster2_test_db`. Use `./server/run_all.sh play` with `server/.env.play`
for the previous `monster2_play_db` environment. The launcher verifies the
actual database identity before either service starts.

The verified gameplay APK is `dist/monster2_gameplay.apk`, SHA256
`2957196b52dc2d86e87e1df8a5ab878aa0bf8f66c91407e17f2bff00af70f90f`.
Keep signed APKs and database backups outside Git.
