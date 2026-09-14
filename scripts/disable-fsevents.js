const Module = require("module");
const origRequire = Module.prototype.require;
Module.prototype.require = function (path) {
  if (
    path === "fsevents" ||
    (typeof path === "string" &&
      (path.endsWith("/fsevents") || path.endsWith("/fsevents.node")))
  ) {
    throw new Error("fsevents disabled for Node 26 compatibility");
  }
  return origRequire.apply(this, arguments);
};
