# Livewire 3 — Pattern e Migrazione

Reference dettagliato per Livewire 3. Consulta quando implementi componenti Livewire o migri da v2 a v3.

---

## Pattern Livewire 3

```php
namespace App\Livewire;

use Livewire\Component;
use Livewire\Attributes\Rule;
use Livewire\Attributes\Computed;

class ContactForm extends Component
{
    #[Rule('required|min:3')]
    public string $name = '';

    #[Rule('required|email')]
    public string $email = '';

    #[Computed]
    public function isValid(): bool
    {
        return strlen($this->name) > 0 && filter_var($this->email, FILTER_VALIDATE_EMAIL);
    }

    public function submit(): void
    {
        $this->validate();
        // logica...
        $this->dispatch('formSubmitted');
        $this->reset(['name', 'email']);
    }
}
```

## Tabella migrazione v2 → v3

| v2 (vecchio) | v3 (corretto) |
|---------------|---------------|
| `App\Http\Livewire` | `App\Livewire` |
| `$this->emit()` | `$this->dispatch()` |
| `$this->emitTo()` | `$this->dispatch()->to()` |
| `$this->dispatchBrowserEvent()` | `$this->dispatch()` |
| `protected $rules = [...]` | `#[Rule('...')]` attribute |
| `protected $listeners = [...]` | `#[On('event')]` attribute |
| `wire:model` (live default) | `wire:model` (deferred default) |
| N/A | `wire:model.live` (per real-time) |
| `$this->queryString` | `#[Url]` attribute |

## Lifecycle hooks

- `mount()` — inizializzazione (equivalente a __construct)
- `hydrate()` — ogni request
- `updated($property)` — dopo aggiornamento property
- `updatedFoo()` — dopo aggiornamento property specifica
- `rendering()` / `rendered()` — prima/dopo render

## Test componenti Livewire

```php
use Livewire\Livewire;

test('form validation works', function () {
    Livewire::test(ContactForm::class)
        ->set('email', 'invalid')
        ->call('submit')
        ->assertHasErrors(['email']);
});

test('successful submission dispatches event', function () {
    Livewire::test(ContactForm::class)
        ->set('name', 'John')
        ->set('email', 'john@example.com')
        ->call('submit')
        ->assertDispatched('formSubmitted');
});
```
