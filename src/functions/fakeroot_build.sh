fakeroot_build() {
  source "${FILE}"
  pkgsetup

  for package in ${pkgname[@]}; do
    msg "Creating package \"${package}\"..."
    unset depends optdepends conflicts provides replaces license

    cd "pkg/${package}/"
    get_variables

    convert_version

    # Delete built package if it exists.
    if find ../../"${package}_${pkgver}_${makedeb_arch}.deb" &> /dev/null; then
      warning2 "Built package detected. Removing..."
      rm ../../"${package}_${pkgver}_${makedeb_arch}.deb"
    fi

    # Convert dependencies, then export data to control file.
    check_distro_dependencies
    remove_dependency_description
    generate_optdepends_fields
    run_dependency_conversion

    msg2 "Generating control file..."
    generate_control "../../${FILE}" > DEBIAN/control

    add_install_scripts

    # Remove leftover build files from makepkg.
    # We don't print a message for this, as there's some spots in makepkg that
    # might make it look redundant.
    for i in '.BUILDINFO' '.MTREE' '.PKGINFO' '.INSTALL' '.Changelog'; do
      rm -f "${i}"
    done

    cd ..

    # Compress into Debian archive
    cd "${package}"
    msg2 "Compressing package..."
    build_deb "${package}"

    mv "${package}_${pkgver}_${makedeb_arch}.deb" ../../

    cd ../..
  done

  msg "Leaving fakeroot environment..."
}
