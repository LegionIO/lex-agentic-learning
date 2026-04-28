# lex-agentic-learning

Domain consolidation gem for learning, adaptation, and knowledge acquisition. Bundles 15 sub-modules into one loadable unit under `Legion::Extensions::Agentic::Learning`.

## Overview

**Gem**: `lex-agentic-learning`
**Version**: 0.1.9
**Namespace**: `Legion::Extensions::Agentic::Learning`

## Sub-Modules

| Sub-Module | Purpose |
|---|---|
| `Learning::Curiosity` | Intrinsic curiosity — knowledge gap detection, wonder queue, salience decay |
| `Learning::EpistemicCuriosity` | Information-gap theory — specific vs. diversive curiosity |
| `Learning::Hebbian` | Cell assembly formation — neurons that fire together wire together |
| `Learning::Habit` | Habit formation — action sequence pattern recognition, maturity stages |
| `Learning::LearningRate` | Dynamic learning rate adaptation based on accuracy and stability |
| `Learning::MetaLearning` | Learning-to-learn — strategy selection per domain |
| `Learning::PreferenceLearning` | Learns stable preferences from choices over time |
| `Learning::Procedural` | Skill acquisition through practice — automatization |
| `Learning::Anchoring` | Anchoring bias in estimation |
| `Learning::Plasticity` | Neural-style plasticity — synaptic weight adjustment |
| `Learning::Scaffolding` | Temporary learning assists that fade as competence grows |
| `Learning::Fermentation` | Time-based transformation of knowledge |
| `Learning::Chrysalis` | Metamorphic state change — transformation through withdrawal |
| `Learning::Catalyst` | Accelerating cognitive transformation |
| `Learning::OutcomeListener` | Outcome-gated learning — listens for task completions and updates meta-learning, learning rate, and scaffolding models |

## Actors

6 actors handle autonomous background processing:

- `Learning::Curiosity::Actor::Decay` — every 300s, decays wonder salience
- `Learning::EpistemicCuriosity::Actor::Decay` — every 300s, decays knowledge gaps
- `Learning::Habit::Actor::Decay` — every 300s, prunes stale habits
- `Learning::Hebbian::Actors::Decay` — every 60s, decays Hebbian assembly connection strength
- `Learning::PreferenceLearning::Actors::Decay` — every 300s, decays older preference observations
- `Learning::OutcomeListener::Actor::OutcomeListener` — **subscription** actor, receives task outcome events and triggers cross-model learning updates; writes lessons to Apollo when enabled

## Installation

```ruby
gem 'lex-agentic-learning'
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
