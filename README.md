# Library-Book-and-Seat-Reservation_Application

## Run the backend locally

Backend MongoDB credentials are stored in `backend/.env`, which is ignored by
Git. To set up another machine, copy `backend/.env.example` to `backend/.env`
and fill in the Atlas username, password, and cluster host.

From PowerShell in the `backend` directory, run:

```powershell
.\run-local.ps1
```

The script loads `.env`, builds the escaped MongoDB connection URI, and runs
`mvn spring-boot:run`. You can also use **Terminal → Run Task…** in VS Code and
select **Backend: Run with local .env**.