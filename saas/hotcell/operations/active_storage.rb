# frozen_string_literal: true

# The five Active Storage operations this cell serves, required one file at a time rather than through the
# gem's entry point. That entry point also loads the ImageMagick and Poppler operations, whose tools this
# image deliberately does not carry, and a cell should advertise only what it can actually do.

require "active_storage/hot_cell/server/transformers/image/vips"
require "active_storage/hot_cell/server/analyzers/image/vips"
require "active_storage/hot_cell/server/analyzers/media/ffprobe"
require "active_storage/hot_cell/server/previewers/pdf/mutool"
require "active_storage/hot_cell/server/previewers/video/ffmpeg"

# The gem's 48MB is too small for a 48MP phone photo. 256MB covers every current phone.
ActiveStorage::HotCell::Server::Transformers::Image::Vips.limits file_size: 256 * 1024**2

# Mirrors config/initializers/vips.rb: openslide segfaults sqlite in forked workers, and tiff is a
# format Fizzy never reads. Workers inherit these from the supervisor.
Vips.block "VipsForeignLoadOpenslide", true
Vips.block "VipsForeignLoadTiff", true
