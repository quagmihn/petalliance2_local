# Start Monster2

Run `./run_all.sh` from this directory, or invoke it by absolute path from
another directory. The default mode is play. For a new checkout, copy
`.env.play.example` to `.env.play`, set the DSN for `monster2_play_db`, and
restrict the file to its owner with `chmod 600 .env.play`.

The launcher uses HTTP 8080 and TCP 5568 by default. Stop any prior launcher
before running it. Ctrl+C shuts down both children. Use `./run_all.sh test` or
`./run_all.sh production` with an explicit `DATABASE_URL` for those modes.
The launcher checks the selected database against the actual PostgreSQL pool.

The validated Waydroid APK SHA256 is
`0d628d671ed4fc69ea71524804d5c6b053ea622db5865c5af438f035752920ac`.
Keep the APK and private database backups outside Git.
