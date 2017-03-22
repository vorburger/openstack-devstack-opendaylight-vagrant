What?
=====

Illustration how to use Daexim to export & re-import part of the datastore.


How?
----

Unless the Daexim feature is already included in your Karaf distribution
(and e.g. in netvirt/vpnservice/distribution/karaf/ used in ../ it's not),
you'll need to build and install it into your local ~/.m2 Maven repository
to be able to install it into Karaf from there:

    git clone https://git.opendaylight.org/gerrit/p/daexim.git
    cd daexim
    mvn [-Pq] -DaddInstallRepositoryPath=../../netvirt/vpnservice/distribution/karaf/target/assembly/system clean install

_The addInstallRepositoryPath= will only work once https://bugs.opendaylight.org/show_bug.cgi?id=8050 is fixed. 
Until then, you have to copy the artifacts from ~/.m2/ into $KARAF_HOME/system (TODO document exact cp command), 
(or use -Dmaven.repo.local=$KARAF_HOME/system; but that has other problems and re-downloads everything),
or temporarily add a dependency to the daexim feature in the pom.xml of your karaf/ build._

Then in OpenDaylight install the Daexim feature `odl-daexim-all` as usual:

    opendaylight-user@root>feature:install odl-daexim-all

Now run the scripts:

    ./daexim-schedule-export.sh

and find `odl_backup_*.json` files in the `$KARAF_HOME/daexim` directory.


ToDo
----

* filter export
** only config, not operational
** only a specific module (e.g. idmanager)
* re-import
