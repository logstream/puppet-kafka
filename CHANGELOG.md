# Change log

## 1.0.2 (March 13, 2014)

BACKWARDS INCOMPATIBILITY:

* Change default value of `$package_ensure` from "latest" to "present".
* Puppet module fails if run on an unsupported platform.  Currently, we only support the RHEL OS family.


## 1.0.1 (March 11, 2014)

IMPROVEMENTS:

* Recursively create directories defined via `$log_dirs` if needed.


## 1.0.0 (February 25, 2014)

* Initial release.

