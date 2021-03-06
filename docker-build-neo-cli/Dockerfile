# Neo node Csharp builder with desired specifications
FROM microsoft/dotnet:2.2-sdk-bionic
LABEL maintainer="NeoResearch"

RUN apt-get update \
    && apt-get install -y zip

# get repo, the arguments should be supplied when building using this Dockerfile
ARG NEO_CLI_BLOCKCHAIN_URL
ARG LOCAL_NEO_CLI_BLOCKCHAIN
RUN mkdir /opt/neoCli 
RUN if [ "$LOCAL_NEO_CLI_BLOCKCHAIN" = "false" ] ; then (git clone $NEO_CLI_BLOCKCHAIN_URL /opt/neoCli);  fi

ARG NEO_BLOCKCHAIN_URL
ARG LOCAL_NEO_BLOCKCHAIN
RUN mkdir /opt/neoLib 
RUN if [ "$LOCAL_NEO_BLOCKCHAIN" = "false" ] ; then (git clone $NEO_BLOCKCHAIN_URL /opt/neoLib);  fi

ARG NEO_CLI_BRANCH
ARG NEO_CLI_COMMIT
RUN if [ "$LOCAL_NEO_CLI_BLOCKCHAIN" = "false" ] ; then (cd /opt/neoCli && git pull && git checkout $NEO_CLI_BRANCH && git checkout $NEO_CLI_COMMIT);  fi

ARG NEO_BLOCKCHAIN_BRANCH
ARG NEO_BLOCKCHAIN_COMMIT
RUN if [ "$LOCAL_NEO_BLOCKCHAIN" = "false" ] ; then (cd /opt/neoLib && git pull && git checkout $NEO_BLOCKCHAIN_BRANCH && git checkout $NEO_BLOCKCHAIN_COMMIT);  fi

#==========================================================================
#============== EXAMPLES FOR CHANGING FILES WITH LOCAL FILES ==============
ARG LOCAL_NEO_CLI_BLOCKCHAIN_URL
RUN mkdir /opt/tempLocal_neoCli
RUN mkdir /opt/tempLocal_neoLib
ADD $LOCAL_NEO_CLI_BLOCKCHAIN_URL /opt/tempLocal_neoCli
RUN if [ "$LOCAL_NEO_CLI_BLOCKCHAIN" = "true" ] ; then (rm -rf /opt/neoCli/; mv /opt/tempLocal_neoCli /opt/neoCli);  fi

ARG LOCAL_NEO_BLOCKCHAIN_URL
ADD $LOCAL_NEO_BLOCKCHAIN_URL /opt/tempLocal_neoLib
RUN if [ "$LOCAL_NEO_BLOCKCHAIN" = "true" ] ; then (rm -rf /opt/neoLib/; mv /opt/tempLocal_neoLib /opt/neoLib);  fi
#==========================================================================
#==========================================================================

#==========================================================================
#============================== PUBLISH NEO-CLI ===========================

#--------------------- CHANGE NEO-VM PATH TO LOCAL FILES -----------------
# NEO-VM special configurations
RUN mkdir /opt/neo-vm
RUN mkdir /opt/tempLocal_neo-vm

ARG SET_NEO_VM
ARG NEO_VM_URL
ARG LOCAL_NEO_VM
RUN if [ "$SET_NEO_VM" = "true" ] && [ "$LOCAL_NEO_VM" = "false" ] ; then git clone $NEO_VM_URL /opt/neo-vm;  fi

ARG NEO_VM_BRANCH
ARG NEO_VM_COMMIT
RUN if [ "$SET_NEO_VM" = "true" ] && [ "$LOCAL_NEO_VM" = "false" ] ; then (cd /opt/neo-vm; git pull; git checkout $NEO_VM_BRANCH; git checkout $NEO_VM_COMMIT);  fi

RUN if [ "$SET_NEO_VM" = "true" ] ; then (dotnet remove /opt/neoLib/neo/neo.csproj package neo.vm; dotnet sln /opt/neoLib/neo.sln add /opt/neo-vm/src/neo-vm/neo-vm.csproj; dotnet add /opt/neoLib/neo/neo.csproj reference /opt/neo-vm/src/neo-vm/neo-vm.csproj);  fi

ARG LOCAL_NEO_VM_URL
ADD $LOCAL_NEO_VM_URL /opt/tempLocal_neo-vm
RUN if [ "$SET_NEO_VM" = "true" ] && [ "$LOCAL_NEO_VM" = "true" ] ; then (rm -rf /opt/neo-vm/; mv /opt/tempLocal_neo-vm /opt/neo-vm);  fi

# Remove neo blockchain package from neo-cli project, referencing it to the local NeoBlockchain Library
RUN dotnet remove /opt/neoCli/neo-cli/neo-cli.csproj package neo
RUN dotnet sln /opt/neoCli/neo-cli.sln add /opt/neoLib/neo/neo.csproj
RUN dotnet add /opt/neoCli/neo-cli/neo-cli.csproj reference /opt/neoLib/neo/neo.csproj
#--------------------------------------------------------------------------

#============================== TESTS NEO AND NEO-TESTS ===================
#---------------------- NEO CORE LIB UNIT TESTS ---------------------------
# Unit tests on Neo - echo "dotnet test --verbosity n /opt/neoLib/neo/neo.UnitTests/neo.UnitTests.csproj"
RUN dotnet test --verbosity n /opt/neoLib/neo.UnitTests/neo.UnitTests.csproj
#---------------------- NEO CORE LIB UNIT TESTS ---------------------------


#--------------------------------------------------------------------------
# publish Neo-cli using defined NeoLib
RUN dotnet publish /opt/neoCli/neo-cli/neo-cli.csproj -o neo-cli -c Release -r ubuntu.16.04-x64
#--------------------------------------------------------------------------
#============================== PUBLISH NEO-CLI ENDS ======================

#---------------------- NEO VM UNIT TESTS---------------------------
RUN if [ "$SET_NEO_VM" = "true" ] ; then (dotnet test --verbosity n /opt/neo-vm/tests/neo-vm.Tests/neo-vm.Tests.csproj);  fi
#--------------------- CHANGE NEO-VM PATH TO LOCAL FILES -----------------

#==========================================================================

#==========================================================================
#=================== PUBLISHING AND ADDING PLUGINS DLL'S ==================
RUN mkdir /opt/neoCli/neo-cli/neo-cli/Plugins/
RUN mkdir /opt/neo-plugins 

ARG NEO_PLUGINS_URL
ARG LOCAL_NEO_PLUGINS
RUN if [ "$LOCAL_NEO_PLUGINS" = "false" ] ; then (git clone $NEO_PLUGINS_URL /opt/neo-plugins);  fi

ARG NEO_PLUGINS_BRANCH
ARG NEO_PLUGINS_COMMIT
RUN if [ "$LOCAL_NEO_PLUGINS" = "false" ] ; then (cd /opt/neo-plugins && git pull && git checkout $NEO_PLUGINS_BRANCH && git checkout $NEO_PLUGINS_COMMIT);  fi
#--------------------------------------------------------------------------
#--------------------- CHANGE PLUGINS PATH TO LOCAL FILES -----------------
ARG LOCAL_NEO_PLUGINS_URL
RUN mkdir /opt/tempLocal_neo-plugins
ADD $LOCAL_NEO_PLUGINS_URL /opt/tempLocal_neo-plugins
RUN if [ "$LOCAL_NEO_PLUGINS" = "true" ] ; then (rm -rf /opt/neo-plugins; mv /opt/tempLocal_neo-plugins /opt/neo-plugins);  fi
#--------------------------------------------------------------------------
ADD building_scripts/build_plugin.sh /opt/
ADD building_scripts/buildAllList_Plugins.sh /opt/

ARG ENVFILE
ADD $ENVFILE /opt/env-repositories.sh
RUN /opt/buildAllList_Plugins.sh

# TODO - Compile and include other plugins
# RUN mkdir /opt/neoCli/neo-cli/neo-cli/Plugins-disabled/
#==========================================================================

#==========================================================================
#============ COMPACT NEO-CLI IN A ZIP FILE  ==============================
RUN cd /opt/neoCli/neo-cli && zip -r /opt/neo-cli-built.zip neo-cli
#==========================================================================

# ALL NIGHT LONG - STAY ALIVE
ENTRYPOINT ["tail", "-f", "/dev/null"]
