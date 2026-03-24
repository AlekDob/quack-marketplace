# Differenze tra Versioni Laravel

Reference completo delle differenze strutturali tra Laravel 9, 10, 11 e 12.
Consulta questo file quando devi decidere quale API, struttura o pattern usare in base alla versione del progetto.

---

## Laravel 12

```
app/
├── Http/Controllers/
├── Http/Requests/
├── Models/
bootstrap/
└── app.php               # Routing, middleware, exceptions (come L11)
routes/
├── web.php
└── api.php               # Se presente
```

- Starter kits rinnovati (React/Vue/Livewire)
- Struttura snella ereditata da L11

## Laravel 11

```
app/
├── Http/Controllers/
├── Http/Requests/
├── Models/
bootstrap/
└── app.php               # Routing, middleware, exceptions — TUTTO QUI
routes/
├── web.php
└── api.php               # NON esiste di default, creare con `artisan install:api`
```

- **NO** `app/Http/Kernel.php` — middleware in `bootstrap/app.php`
- **NO** `app/Http/Middleware/` di default — middleware inline o classi custom registrate in `bootstrap/app.php`
- **NO** `app/Providers/RouteServiceProvider.php` — routing in `bootstrap/app.php`
- **NO** `app/Console/Kernel.php` — schedule in `routes/console.php`
- Config minimale: solo i file di config che differiscono dal default vengono pubblicati

## Laravel 10

```
app/
├── Console/
│   └── Kernel.php            # Schedule
├── Exceptions/
│   └── Handler.php           # Exception handling
├── Http/
│   ├── Controllers/
│   ├── Kernel.php            # Middleware stack
│   ├── Middleware/            # Middleware classes
│   └── Requests/
├── Models/
├── Providers/
│   ├── AppServiceProvider.php
│   ├── AuthServiceProvider.php
│   ├── EventServiceProvider.php
│   └── RouteServiceProvider.php
routes/
├── api.php
├── web.php
└── channels.php
```

- Struttura classica con Kernel, Handler, ServiceProviders dedicati
- Middleware in `app/Http/Middleware/`
- Route model binding e prefissi API in `RouteServiceProvider`

## Laravel 9 e precedenti

- Simile a L10 con alcune differenze minori
- `$casts` come property array (non metodo `casts()`)
- Route groups con namespace controller esplicito

---

## Tabella differenze rapida

| Aspetto | L9 | L10 | L11 | L12 |
|---------|----|----|-----|-----|
| Middleware | `Http/Kernel.php` | `Http/Kernel.php` | `bootstrap/app.php` | `bootstrap/app.php` |
| Exceptions | `Exceptions/Handler.php` | `Exceptions/Handler.php` | `bootstrap/app.php` | `bootstrap/app.php` |
| Schedule | `Console/Kernel.php` | `Console/Kernel.php` | `routes/console.php` | `routes/console.php` |
| Route config | `RouteServiceProvider` | `RouteServiceProvider` | `bootstrap/app.php` | `bootstrap/app.php` |
| API routes | Esiste di default | Esiste di default | `artisan install:api` | `artisan install:api` |
| Casts | `$casts` property | `$casts` property | `casts()` metodo | `casts()` metodo |
| Config files | Tutti pubblicati | Tutti pubblicati | Solo diff da default | Solo diff da default |
