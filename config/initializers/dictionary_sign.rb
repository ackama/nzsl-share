# Conditionally switch between dictionary sign models based on an environment variable.
# This allows us to quickly switch between searching Freelex and Signbank data for signs.

dictionary_mode = ENV["DICTIONARY_MODE"]&.downcase
dictionary_sign_model = dictionary_mode == "freelex" ? FreelexSign : DictionarySign
Rails.application.config.dictionary_sign_model = dictionary_sign_model
