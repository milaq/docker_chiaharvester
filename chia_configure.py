#!/usr/bin/env python3

import os
import sys
import yaml

# override problematic lazy anchors
class NoAliasDumper(yaml.Dumper):
    def ignore_aliases(self, data):
        return True

if len(sys.argv) < 2 or not os.path.isfile(sys.argv[1]):
    print("Error: Missing or invalid configfile")
    sys.exit(1)
configfile_path=sys.argv[1]

with open(configfile_path) as configfile:
    print("Initial config file parsing of %s" % configfile_path)
    config = yaml.safe_load(configfile)

    config['self_hostname'] = "127.0.0.1"
    config['logging']['log_stdout'] = True
    config['logging']['log_level'] = "INFO"

    with open(configfile_path, 'w') as configfile:
        yaml.dump(config, configfile, Dumper=NoAliasDumper)
        print("Successfully sanitized config file %s" % configfile_path)

with open(configfile_path) as configfile:
    print("Configuring harvester in %s" % configfile_path)
    config = yaml.safe_load(configfile)

    config['harvester']['logging']['log_level'] = os.getenv('HARVESTER_LOGLEVEL')
    config['harvester']['farmer_peer']['host'] = os.getenv('FARMER_HOST')
    if os.getenv('FARMER_PORT'):
        config['harvester']['farmer_peer']['port'] = int(os.getenv('FARMER_PORT'))
    config['harvester']['plot_loading_frequency_seconds'] = int(os.getenv('PLOTS_REFRESH_FREQUENCY'))
    config['harvester']['plot_directories'] = [ os.getenv('PLOTSDIR') ]

    with open(configfile_path, 'w') as configfile:
        yaml.dump(config, configfile, Dumper=NoAliasDumper)
        print("Successfully configured harvester in %s" % configfile_path)
