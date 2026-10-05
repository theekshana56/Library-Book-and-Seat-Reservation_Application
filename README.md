# Library-Book-and-Seat-Reservation_Application

## Vendor accounts

Vendors can choose **Vendor** on the registration screen and apply using their
contact name, company/publisher name, email, and password; no university ID is
required. A library administrator must activate the pending vendor account from
**Library operations → User accounts** before it can sign in. Approved vendors
use their email address and password to open the vendor portal, manage book
offers, and view proposal decisions. Vendor proposal access is scoped to the
signed-in account.

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

For the Android app, connect the device with USB debugging enabled, start the
backend, and run **Flutter: Run on 25028RN03A** from VS Code. That task uses
`adb reverse` to connect the app to `localhost:8080`, avoiding a fixed Wi-Fi IP
and allowing the computer and phone to be on different networks. ADB must be
installed and the device authorized by the computer.