# lex-agentic-learning

**Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## What Is This Gem?

Domain consolidation gem for learning, adaptation, and knowledge acquisition. Bundles 14 source extensions into one loadable unit under `Legion::Extensions::Agentic::Learning`.

**Gem**: `lex-agentic-learning`
**Version**: 0.1.1
**Namespace**: `Legion::Extensions::Agentic::Learning`

## Sub-Modules

| Sub-Module | Source Gem | Purpose |
|---|---|---|
| `Learning::Curiosity` | `lex-curiosity` | Intrinsic curiosity — knowledge gap detection, wonder queue, salience decay |
| `Learning::EpistemicCuriosity` | `lex-epistemic-curiosity` | Information-gap theory — specific vs. diversive curiosity |
| `Learning::Hebbian` | `lex-hebbian-assembly` | Cell assembly formation — neurons that fire together wire together |
| `Learning::Habit` | `lex-habit` | Habit formation — action sequence pattern recognition, maturity stages |
| `Learning::LearningRate` | `lex-learning-rate` | Dynamic learning rate adaptation based on accuracy and stability |
| `Learning::MetaLearning` | `lex-meta-learning` | Learning-to-learn — strategy selection per domain |
| `Learning::PreferenceLearning` | `lex-preference-learning` | Learns stable preferences from choices over time |
| `Learning::Procedural` | `lex-procedural-learning` | Skill acquisition through practice — automatization |
| `Learning::Anchoring` | `lex-anchoring` | Anchoring bias in estimation |
| `Learning::Plasticity` | `lex-cognitive-plasticity` | Neural-style plasticity — synaptic weight adjustment |
| `Learning::Scaffolding` | `lex-cognitive-scaffolding` | Temporary learning assists that fade as competence grows |
| `Learning::Fermentation` | `lex-cognitive-fermentation` | Time-based transformation of knowledge |
| `Learning::Chrysalis` | `lex-cognitive-chrysalis` | Metamorphic state change — transformation through withdrawal |
| `Learning::Catalyst` | `lex-cognitive-catalyst` | Accelerating cognitive transformation |

## Tick Integration

`Learning::Curiosity` maps to the `working_memory_integration` tick phase via `detect_gaps`.

## Development

```bash
bundle install
bundle exec rspec        # 1316 examples, 0 failures
bundle exec rubocop      # 0 offenses
```
