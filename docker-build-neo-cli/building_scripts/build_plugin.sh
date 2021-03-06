#!/bin/bash
PLUGIN_TO_INCLUDE=1

function usage {
    echo "Usage: $0 [--plugin-name <plugin to build>]"
}

while [[ "$#" > 0 ]]; do case $1 in
    -h)
        usage
        exit 0
        ;;
    --plugin-name)
	echo "Getting plugin name as parameter $2";
        PLUGIN_TO_INCLUDE=$2
        shift; shift
        ;;
    *)
        usage
        exit 1
        ;;
  esac;
done

dotnet remove /opt/neo-plugins/$PLUGIN_TO_INCLUDE/$PLUGIN_TO_INCLUDE.csproj package neo
dotnet sln /opt/neoCli/neo-cli.sln add /opt/neo-plugins/$PLUGIN_TO_INCLUDE/$PLUGIN_TO_INCLUDE.csproj
dotnet add /opt/neo-plugins/$PLUGIN_TO_INCLUDE/$PLUGIN_TO_INCLUDE.csproj reference /opt/neoLib/neo/neo.csproj
dotnet publish /opt/neo-plugins/$PLUGIN_TO_INCLUDE/$PLUGIN_TO_INCLUDE.csproj -o $PLUGIN_TO_INCLUDE -c Release -r ubuntu.16.04-x64 -f netstandard2.0
if [ ! -f /opt/neo-plugins/$PLUGIN_TO_INCLUDE/$PLUGIN_TO_INCLUDE/$PLUGIN_TO_INCLUDE.dll ]; then
    echo "File does not exist"
    exit 1
fi

echo ""
echo "dotnet test --verbosity n /opt/neo-plugins/$PLUGIN_TO_INCLUDE.UnitTests/$PLUGIN_TO_INCLUDE.UnitTests.csproj"
dotnet test --verbosity n /opt/neo-plugins/$PLUGIN_TO_INCLUDE.UnitTests/$PLUGIN_TO_INCLUDE.UnitTests.csproj
echo ""


cp -ri /opt/neo-plugins/$PLUGIN_TO_INCLUDE/$PLUGIN_TO_INCLUDE/$PLUGIN_TO_INCLUDE.dll /opt/neoCli/neo-cli/neo-cli/Plugins/
