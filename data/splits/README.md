# File Format:

``split_strategy/<language>_<seed#>(_<training/finetune size>).<train, finetune, dev, test, or gold>``

- Full training data is the union of train and finetune. Models that do not need a separate fine tuning set should be trained on train+finetune
- Dev set is for evaluation during development. Do not train or fine-tune  on dev.
- Gold and test are the same, except test does not contain the inflected forms.
