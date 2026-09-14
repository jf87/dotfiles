#!/bin/sh

echo Enabling vpnagentd...
sudo launchctl enable system/com.cisco.anyconnect.vpnagentd

echo Bootstrapping vpnagentd...
sudo launchctl bootstrap system /Library/LaunchDaemons/com.cisco.anyconnect.vpnagentd.plist
