const sourcePath = "app/front_assets";
const sourceEntryPath = "packs";
const publicRootPath = "public";
const publicOutputPath = "packs";
const publicTestOutputPath = "test-packs";
const additionalPaths = [ ];
const cachePath ="tmp/cache/webpack"
const devServerPort = 3035;

module.exports = {
  sourcePath,
  sourceEntryPath,
  publicRootPath,
  publicOutputPath,
  publicTestOutputPath,
  additionalPaths,
  devServerPort,
  cachePath
}