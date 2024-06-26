#!/bin/bash
/root/spdk/scripts/setup.sh
/root/spdk/scripts/gen_nvme.sh --json-with-subsystems > /tmp/bdev.json