# Error Patterns — Laravel Debugging Reference

Tabelle di pattern di errore comuni in Laravel, organizzate per categoria.
Consulta questo file durante il debugging per identificare rapidamente root cause e fix.

---

## Database

| Pattern errore | Root cause | Fix |
|----------------|------------|-----|
| `Base table or view not found` | Tabella mancante | Esegui migration o crea tabella |
| `Column not found` | Colonna mancante | Aggiungi colonna via migration |
| `Duplicate entry` | Vincolo unique violato | Gestisci duplicato o modifica vincolo |
| `Foreign key constraint` | FK reference mancante | Crea tabella/colonna referenziata |
| `Connection refused` | Config DB errata | Correggi .env |

## Auth

| Pattern errore | Root cause | Fix |
|----------------|------------|-----|
| `Unauthenticated` | Nessun token auth | Aggiungi middleware auth |
| `Unauthorized` (403) | Policy nega accesso | Aggiorna policy o permessi |
| `User not found` | Model lookup fallito | Verifica query utente |

## Validation

| Pattern errore | Root cause | Fix |
|----------------|------------|-----|
| `The given data was invalid` | Validazione fallisce | Aggiorna regole o dati input |
| `ValidationException` | Regola violata | Correggi logica validazione |

## Container/IoC

| Pattern errore | Root cause | Fix |
|----------------|------------|-----|
| `Target class does not exist` | Binding mancante | Registra in ServiceProvider |
| `Interface not instantiable` | Implementation mancante | Binda implementazione a interfaccia |

## Route

| Pattern errore | Root cause | Fix |
|----------------|------------|-----|
| `Route [x] not defined` | Named route mancante | Definisci nome route |
| `Action not defined` | Metodo controller mancante | Aggiungi metodo o correggi route |
