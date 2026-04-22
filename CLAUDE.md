# lex-agentic-learning

**Parent**: `../CLAUDE.md`

## What Is This Gem?

Domain consolidation gem for learning, adaptation, and knowledge acquisition. Bundles 15 sub-modules into one loadable unit under `Legion::Extensions::Agentic::Learning`.

**Gem**: `lex-agentic-learning`
**Version**: 0.1.8
**Namespace**: `Legion::Extensions::Agentic::Learning`

## Sub-Modules

| Sub-Module | Source Gem | Purpose | Runner Methods |
|---|---|---|---|
| `Learning::Curiosity` | `lex-curiosity` | Intrinsic curiosity — knowledge gap detection, wonder queue, salience decay | `detect_gaps`, `add_wonder`, `decay_wonders`, `curiosity_status` |
| `Learning::EpistemicCuriosity` | `lex-epistemic-curiosity` | Information-gap theory — specific vs. diversive curiosity | `add_knowledge_gap`, `decay_gaps`, `epistemic_curiosity_status` |
| `Learning::Hebbian` | `lex-hebbian-assembly` | Cell assembly formation — neurons that fire together wire together | `fire_units`, `decay`, `hebbian_assembly_status` |
| `Learning::Habit` | `lex-habit` | Habit formation — action sequence pattern recognition, maturity stages | `record_action`, `decay_habits`, `habit_status` |
| `Learning::LearningRate` | `lex-learning-rate` | Dynamic learning rate adaptation based on accuracy and stability | `update_learning_rate`, `learning_rate_status` |
| `Learning::MetaLearning` | `lex-meta-learning` | Learning-to-learn — strategy selection per domain | `update_strategy`, `meta_learning_status` |
| `Learning::PreferenceLearning` | `lex-preference-learning` | Learns stable preferences from choices over time | `record_choice`, `decay`, `preference_learning_status` |
| `Learning::Procedural` | `lex-procedural-learning` | Skill acquisition through practice — automatization | `procedural_learning`, `procedural_learning_status` |
| `Learning::Anchoring` | `lex-anchoring` | Anchoring bias in estimation | `anchoring`, `anchoring_status` |
| `Learning::Plasticity` | `lex-cognitive-plasticity` | Neural-style plasticity — synaptic weight adjustment | `cognitive_plasticity`, `plasticity_status` |
| `Learning::Scaffolding` | `lex-cognitive-scaffolding` | Temporary learning assists that fade as competence grows | `cognitive_scaffolding`, `scaffolding_status` |
| `Learning::Fermentation` | `lex-cognitive-fermentation` | Time-based transformation of knowledge | `cognitive_fermentation`, `fermentation_status` |
| `Learning::Chrysalis` | `lex-cognitive-chrysalis` | Metamorphic state change — transformation through withdrawal | `cognitive_chrysalis`, `chrysalis_status` |
| `Learning::Catalyst` | `lex-cognitive-catalyst` | Accelerating cognitive transformation | `cognitive_catalyst`, `catalyst_status` |
| `Learning::OutcomeListener` | (inline) | Outcome-gated learning — listens for task completions and updates meta-learning, learning rate, and scaffolding models; writes lessons to Apollo when enabled | `process_outcome`, `outcome_listener_status` |

## Actors

All actors extend `Legion::Extensions::Actors::Every` or `Actors::Subscription`.

| Actor | Type | Interval / Trigger | Target Method |
|---|---|---|---|
| `Learning::Curiosity::Actor::Decay` | Every | 300s | `Curiosity#decay_wonders` |
| `Learning::EpistemicCuriosity::Actor::Decay` | Every | 300s | `EpistemicCuriosity#decay_gaps` |
| `Learning::Habit::Actor::Decay` | Every | 300s | `Habit#decay_habits` |
| `Learning::Hebbian::Actors::Decay` | Every | 60s | `HebbianAssembly#decay` |
| `Learning::PreferenceLearning::Actors::Decay` | Every | 300s | `PreferenceLearning#decay` |
| `Learning::OutcomeListener::Actor::OutcomeListener` | Subscription | task outcome events | `OutcomeListener#process_outcome` |

`OutcomeListener` is a **Subscription** actor (not Every). It is guarded by `defined?(Legion::Extensions::Actors::Subscription)` and requires transport to be connected. Enabled/disabled via `Legion::Settings.dig(:agentic, :learning, :outcome_listener)` (defaults to enabled). On receiving a task outcome event, it triggers cross-model updates to meta-learning, learning rate, and scaffolding; optionally writes lessons to Apollo.

## Dependencies

| Gem | Purpose |
|---|---|
| `legion-cache` >= 1.3.11 | Cache access |
| `legion-crypt` >= 1.4.9 | Encryption/Vault |
| `legion-data` >= 1.4.17 | DB persistence |
| `legion-json` >= 1.2.1 | JSON serialization |
| `legion-logging` >= 1.3.2 | Logging |
| `legion-settings` >= 1.3.14 | Settings |
| `legion-transport` >= 1.3.9 | AMQP |

## Tick Integration

- `Learning::Curiosity` maps to the `working_memory_integration` tick phase via `detect_gaps`
- `Learning::OutcomeListener` integrates with the task completion event stream (subscription-based, not tick-based)

## Development

```bash
bundle install
bundle exec rspec        # 0 failures
bundle exec rubocop      # 0 offenses
```
