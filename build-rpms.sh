#!/bin/bash
echo "-- Installing build dependencies defined in recipe.yml. --" 
echo "If you do not want them removed after build is completed, put them in pkgs instead."
rpm_deps=$(yq '.deps[]' < /tmp/ublue-recipe.yml)
for dep in $(echo -e "$rpm_deps"); do \
    echo "Installing: ${dep}" && \
    dnf install $dep -y; \
done
echo "---"

echo "-- Building mangohud --"
cd /tmp/rpm/mangohud/rpmbuild/SOURCES
rpmspectool get /tmp/rpm/mangohud/mangohud.spec
ls -R /tmp/rpm/mangohud
rpmbuild -ba \
    --define '_topdir /tmp/rpm/mangohud/rpmbuild' \
    --define '%_tmppath %{_topdir}/tmp/rpm' \
    /tmp/rpm/mangohud/mangohud.spec
echo "---"