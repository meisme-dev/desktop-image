#!/bin/bash
# remove the default firefox (from fedora) in favor of the flatpak
rpm-ostree override remove firefox firefox-langpacks

echo "-- Installing build dependencies defined in recipe.yml. --" 
echo "If you do not want them removed after build is completed, put them in pkgs instead."
rpm_deps=$(yq '.deps[]' < /tmp/ublue-recipe.yml)
for dep in $(echo -e "$rpm_deps"); do \
    echo "Installing: ${dep}" && \
    rpm-ostree install $dep; \
done
echo "---"

echo "-- Building mangohud --"
rpmbuild -ba \
    --define '_topdir /tmp/mangohud/rpmbuild' \
    --define '%_tmppath %{_topdir}/tmp' \
    /tmp/mangohud/mangohud.spec
echo "---"

echo "-- Installing RPMs defined in recipe.yml --"
rpm_packages=$(yq '.rpms[]' < /tmp/ublue-recipe.yml)
for pkg in $(echo -e "$rpm_packages"); do \
    echo "Installing: ${pkg}" && \
    rpm-ostree install $pkg; \
done
echo "---"

# install yafti to install flatpaks on first boot, https://github.com/ublue-os/yafti
pip install --prefix=/usr yafti

# add a package group for yafti using the packages defined in recipe.yml
yq -i '.screens.applications.values.groups.Custom.description = "Flatpaks defined by the image maintainer"' /etc/yafti.yml
yq -i '.screens.applications.values.groups.Custom.default = true' /etc/yafti.yml
flatpaks=$(yq '.flatpaks[]' < /tmp/ublue-recipe.yml)
for pkg in $(echo -e "$flatpaks"); do \
    yq -i ".screens.applications.values.groups.Custom.packages += [{\"$pkg\": \"$pkg\"}]" /etc/yafti.yml
done

echo "-- Removing build dependencies defined in recipe.yml --"
for dep in $(echo -e "$rpm_deps"); do \
    echo "Removing: ${dep}" && \
    rpm-ostree uninstall $dep; \
done
echo "---"
