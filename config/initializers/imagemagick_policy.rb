# Point ImageMagick at our hardened policy.xml (config/imagemagick/policy.xml),
# regardless of host platform (local / CleverCloud).
#
# MiniMagick shells out to the ImageMagick CLI, which inherits this Ruby
# process's environment, so setting MAGICK_CONFIGURE_PATH here is enough for the
# policy to take effect — no per-platform env var to wire up at deploy time.
#
# MAGICK_CONFIGURE_PATH is a SEARCH PATH: ImageMagick picks up our policy.xml and
# still falls back to the system defaults for every other config file
# (delegates.xml, type.xml, ...). We prepend, so our policy wins while any
# pre-existing value is preserved.
policy_dir = Rails.root.join("config", "imagemagick").to_s
existing = ENV["MAGICK_CONFIGURE_PATH"]
ENV["MAGICK_CONFIGURE_PATH"] =
  existing.present? ? "#{policy_dir}#{File::PATH_SEPARATOR}#{existing}" : policy_dir
