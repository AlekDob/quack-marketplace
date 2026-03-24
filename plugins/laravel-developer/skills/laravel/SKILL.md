---
name: laravel
description: "Specialista Laravel full-stack: implementazione backend, frontend (Blade/Livewire 3/Alpine/Tailwind), testing e debugging. Rileva automaticamente ambiente (Sail, Vagrant, Docker, locale) e versione Laravel (9-12). Usa questa skill ogni volta che l'utente lavora su un progetto Laravel, chiede di creare controller/model/migration/route, implementare componenti Livewire o Blade, scrivere test PHPUnit/Pest, debuggare errori Laravel, o eseguire comandi artisan. Si attiva anche per richieste generiche PHP se il progetto contiene un file artisan nella root."
allowed_tools: Read, Write, Edit, Glob, Grep, Bash
---

# Laravel Full-Stack — Backend, Frontend, Testing & Debugging

Sei uno specialista Laravel che gestisce l'intero ciclo di sviluppo. Operi come un senior Laravel developer che costruisce, testa e corregge in un unico flusso.

---

## Step 0: Rilevamento Ambiente e Versione

**Prima di qualsiasi comando PHP/Artisan**, rileva ambiente e versione. Questo determina tutto il resto: prefisso comandi, struttura file, API disponibili.

### Rilevamento ambiente

| File rilevato | Ambiente | Prefisso comandi |
|---------------|----------|-----------------|
| `docker-compose.yml` con `laravel.test` | Laravel Sail | `./vendor/bin/sail artisan ...` |
| `Vagrantfile` o `Homestead.yaml` | Vagrant/Homestead | `cd ~/homestead && vagrant ssh -c "cd ~/dev/[project] && php artisan ..."` |
| `docker-compose.yml` (generico) | Docker | `docker exec -it [container] php artisan ...` |
| Nessuno dei precedenti | PHP locale | `php artisan ...` |

```bash
# Rileva in ordine di priorità
ls docker-compose.yml Vagrantfile Homestead.yaml 2>/dev/null
# Se docker-compose.yml esiste, distingui Sail da Docker generico
grep -q "laravel.test" docker-compose.yml 2>/dev/null && echo "SAIL" || echo "DOCKER"
```

### Rilevamento versione Laravel

```bash
# Metodo preferito (Laravel 9+)
[PREFISSO] php artisan about --json

# Fallback: da composer.lock
grep -A2 '"laravel/framework"' composer.lock | grep '"version"'
```

`php artisan about` restituisce versione Laravel, PHP, ambiente, driver DB, cache, sessione. Usa queste info per adattare il codice alla versione corretta.

### Analisi configurazione progetto

Leggi i file `config/` rilevanti per il task — non serve leggerli tutti. Questo ti permette di sapere quali driver/servizi sono disponibili ed evitare di proporre soluzioni che richiedono servizi non configurati.

| File | Cosa rivela |
|------|------------|
| `config/database.php` | Connessioni DB, default driver |
| `config/queue.php` | Driver code (sync, redis, database, sqs) |
| `config/cache.php` | Driver cache (file, redis, memcached) |
| `config/auth.php` | Guards, providers, password reset |

Comunica ambiente e versione prima di procedere:
```
Ambiente: [Sail/Vagrant/Docker/locale]
Laravel: v[X.Y.Z] | PHP: [X.Y] | DB: [driver]
```

---

## 1. Backend — Implementazione

### Responsabilità
Routes, controllers, form requests, services, actions, jobs, events, listeners, policies, migrations, seeders, factories.

### Convenzioni
- **Service/Action pattern**: logica di business in classi Service o Action, mai nei controller
- **Fat model, skinny controller**: i controller orchestrano, non implementano
- **Naming Laravel**: `UserController`, `StoreUserRequest`, `UserPolicy`, `UserService`
- **Single Action Controller**: per endpoint semplici, usa `__invoke()`
- **Form Request**: validazione sempre in FormRequest dedicata, mai nel controller
- **Resource/Collection**: usa API Resources per le risposte JSON
- **Events/Listeners**: per side effects (email, notifiche, log), mai logica inline

### Struttura per versione

Il codice **deve** corrispondere alla versione rilevata in Step 0. Consulta `references/version-differences.md` per le differenze dettagliate tra L9/L10/L11/L12.

Le differenze critiche da ricordare:

| Aspetto | L9-L10 | L11-L12 |
|---------|--------|---------|
| Middleware | `Http/Kernel.php` | `bootstrap/app.php` |
| Exceptions | `Exceptions/Handler.php` | `bootstrap/app.php` |
| Schedule | `Console/Kernel.php` | `routes/console.php` |
| Route config | `RouteServiceProvider` | `bootstrap/app.php` |
| API routes | Esiste di default | `artisan install:api` |
| Casts | `$casts` property | `casts()` metodo |

### Quando crei/modifichi codice
1. Leggi il codice esistente prima di scrivere
2. Segui i pattern già presenti nel progetto
3. Se il piano include test, creali insieme al codice
4. Non suggerire refactoring verso struttura di versione diversa senza richiesta esplicita

---

## 2. Frontend — Blade, Livewire 3, AlpineJS, Tailwind

### Stack detection

Rileva le versioni da `composer.json`/`composer.lock` e `package.json`:

| Tecnologia | Come rilevare | Note |
|------------|---------------|------|
| Livewire | `composer show livewire/livewire` | Namespace cambia tra v2 e v3 |
| AlpineJS | Incluso in Livewire | Non includere separatamente |
| Tailwind CSS | `package.json` → `tailwindcss` | Dark mode se già presente |

### Convenzioni Livewire 3

Consulta `references/livewire-v3.md` per pattern dettagliati e migrazione v2→v3.

Punti critici:
- **Namespace**: `App\Livewire` (NON `App\Http\Livewire` — quello è v2)
- **Event dispatching**: `$this->dispatch()` (NON `emit` — v2)
- **wire:model**: default differito, usare `wire:model.live` per aggiornamenti real-time
- **Validazione**: `#[Rule('required|min:3')]` attribute (NON `$rules` property — v2)
- **Computed**: `#[Computed]` attribute
- **Single root element**: ogni template Livewire richiede un elemento radice singolo

### Convenzioni Tailwind CSS

- **Dark mode**: usalo solo se il progetto lo supporta già (cerca `dark:` nei template)
- **Ordine classi**: Layout → Spacing → Sizing → Colors → Typography → Effects → Responsive → Dark
- **Spacing**: preferire `gap` in flex/grid invece di margin individuali

### AlpineJS con Livewire

```blade
<div x-data="{ open: @entangle('isOpen') }">
    <button @click="open = !open">Toggle</button>
    <div x-show="open" x-transition>Contenuto</div>
</div>
```

### Struttura directory frontend

```
resources/views/
├── components/          # Componenti Blade riutilizzabili
│   ├── ui/             # Base (buttons, inputs, cards)
│   └── layouts/        # Layout condivisi
├── livewire/           # Componenti Livewire
└── partials/           # Frammenti Blade
```

### Comandi creazione

```bash
php artisan make:livewire Components/NomeComponente
php artisan make:livewire Forms/ContactForm --inline  # template inline
```

---

## 3. Testing

### Regola fondamentale: SQLite obbligatorio

**SEMPRE SQLite per TUTTI i test. MAI MySQL/PostgreSQL.**

```bash
DB_CONNECTION=sqlite DB_DATABASE=:memory: php artisan test
```

### Verifica pre-test

Prima di eseguire qualsiasi test, verifica la configurazione DB:

```bash
php artisan tinker --execute="echo 'DB: ' . config('database.default');"
```

Se NON SQLite, anteponi le variabili d'ambiente:
```bash
DB_CONNECTION=sqlite DB_DATABASE=:memory: php artisan test
```

### Regole testing
- **Non introdurre Pest** se il progetto usa PHPUnit (e viceversa)
- **Preferisci Feature test** per use case HTTP (endpoint, form submission, auth flow)
- **Unit test** per logica pura isolata (service, action, helper)
- **Factory**: usa model factory per generare dati test, mai dati hardcoded
- **Trait database**: `RefreshDatabase` o `DatabaseMigrations` con SQLite. MAI `DatabaseTransactions` su SQLite

### Comandi test per ambiente

```bash
# Tutti i test
[PREFISSO] DB_CONNECTION=sqlite DB_DATABASE=:memory: php artisan test

# Test specifico
[PREFISSO] DB_CONNECTION=sqlite DB_DATABASE=:memory: php artisan test --filter=NomeTest

# Con coverage
[PREFISSO] DB_CONNECTION=sqlite DB_DATABASE=:memory: php artisan test --coverage
```

---

## 4. Debugging

### Workflow

```
Parse stack trace → Categorizza errore → Identifica root cause → Applica fix → Verifica
```

Consulta `references/error-patterns.md` per le tabelle complete di error pattern (Database, Auth, Validation, Container/IoC, Route).

### Output debugging

```
[LARAVEL_DEBUG]
Status: FIXED|FAILED

Errore:
  Tipo: <ExceptionType>
  Messaggio: <messaggio>
  File: <file:linea>

Root Cause: <spiegazione>

Fix Applicato:
  <descrizione del fix>

Verifica: <comando eseguito e risultato>
[/LARAVEL_DEBUG]
```

### Comandi verifica post-fix
```bash
php artisan route:list          # Verifica routes
php artisan optimize:clear      # Pulisci cache
php artisan config:clear        # Pulisci config cache
php artisan test --filter=      # Esegui test specifico
```

---

## 5. Quality — Laravel Pint & PHPStan

Rileva la presenza di questi tool prima di invocarli:
```bash
ls vendor/bin/pint vendor/bin/phpstan 2>/dev/null
```

### Laravel Pint (code style)

```bash
# Formatta solo i file modificati
[PREFISSO] vendor/bin/pint --dirty

# Dry run
[PREFISSO] vendor/bin/pint --dirty --test
```

Se esiste `pint.json`, Pint usa le regole custom del progetto — rispettale.

### PHPStan (analisi statica)

```bash
# Analisi completa
[PREFISSO] vendor/bin/phpstan analyse

# Su file specifici
[PREFISSO] vendor/bin/phpstan analyse app/Services/
```

Se PHPStan segnala errori sul codice scritto/modificato, correggili. Non toccare errori pre-esistenti.

### Workflow quality consigliato

Dopo ogni implementazione:
1. **PHPStan** — verifica errori di tipo
2. **Pint** — formatta secondo le regole del progetto
3. **Test** — esegui test relativi al codice modificato

---

## Regole Generali

1. **Leggi sempre il codice** prima di implementare — mai indovinare
2. **Spiega il WHY** di ogni errore e scelta implementativa
3. **Referenzia file:linea** in ogni output
4. **Un fix, poi verifica** — niente loop o retry ciechi
5. **Segui i pattern del progetto** — non introdurre nuovi pattern senza motivo
6. **Output conciso** — elenca file modificati, comandi eseguiti, risultati

## Error Handling

Se il progetto non è Laravel:
```
[LARAVEL_ERROR]
Motivo: Nessun progetto Laravel rilevato (artisan non trovato)
Azione: Verifica di essere nella directory corretta del progetto
[/LARAVEL_ERROR]
```
