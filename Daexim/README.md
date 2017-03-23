What?
=====

Illustration how to use Daexim to export & re-import part of the datastore.


How?
----

Unless the Daexim feature is already included in your Karaf distribution
(and e.g. in netvirt/vpnservice/distribution/karaf/ used in ../ it's not),
you'll need to build and install it into your Karaf's Maven repository
to be able to install it into Karaf from there:

    git clone https://git.opendaylight.org/gerrit/p/daexim.git
    cd daexim
    mvn [-Pq] clean install

You can either temporarily add a dependency to the daexim feature in the pom.xml of your karaf/ build.

What's often easier however is to just copy the artifacts from ~/.m2/ into $KARAF_HOME/system, like so:

    mkdir -p ../netvirt/vpnservice/distribution/karaf/target/assembly/system/org/opendaylight/daexim/
    cp -vR ~/.m2/repository/org/opendaylight/daexim/ ../netvirt/vpnservice/distribution/karaf/target/assembly/system/org/opendaylight/

_Once https://bugs.opendaylight.org/show_bug.cgi?id=8050 is fixed, you'll be able to instead of above just do:
(This is better than using -Dmaven.repo.local=$KARAF_HOME/system; as that has other problems and re-downloads everything.)_

    mvn [-Pq] -DaddInstallRepositoryPath=../../netvirt/vpnservice/distribution/karaf/target/assembly/system clean install

We now have to add the maven artifact of the features repository to our OpenDaylight Karaf instance:

    opendaylight-user@root>repo-add mvn:org.opendaylight.daexim/daexim-features/1.0.0-SNAPSHOT/xml/features

Then you can install the Daexim feature `odl-daexim-all` as usual:

    opendaylight-user@root>feature:install odl-daexim-all

Now run the scripts:

    ./daexim-schedule-export.sh

and find `odl_backup_*.json` files in the `$KARAF_HOME/daexim` directory.


ToDo
----

* DEV to filter export by include instead of exclude, for list of specific modules (e.g. idmanager)
* re-import
