%global _python_bytecompile_extra 0
%global debug_package %{nil}

Name:           %name
Version:        %version
Release:        %{!release:1}%{?dist}
Summary:        The PATRIC Command Line Interface

License:        MIT
URL:            https://patricbrc.org/
Source0:        %source

BuildRequires:  perl-Template-Toolkit perl-File-Slurp perl-Path-Tiny perl-local-lib gcc-c++
Requires:       perl

AutoReqProv: no

%description

The PATRIC Command Line Interface.

%prep
%autosetup


%build

env KB_IGNORE_MISSING_DEPENDENCIES=1 ./bootstrap /usr
source ./user-env.sh
make

%install
export QA_RPATHS=$(( 0x0001|0x0010 ))

mkdir -p %{buildroot}/usr/share/%name-%version/local

eval `perl -Mlocal::lib=%{buildroot}/usr/share/%name-%version/local`

# PERL MODULES

source ./user-env.sh

perl auto-deploy \
     --target %{buildroot}/usr/share/%name-%version \
     --override KB_OVERRIDE_TOP=/usr/share/%name-%version \
     --override KB_OVERRIDE_PERL_PATH=/usr/share/%name-%version/lib:/usr/share/%name-%version/local/lib/perl5 \
     --override KB_OVERRIDE_PYTHON_PATH=/usr/share/%name-%version/lib \
     deploy.cfg

echo "/usr/share/%name-%version" > %{_topdir}/files
mkdir -p %{buildroot}/usr/bin

for file in %{buildroot}/usr/share/%name-%version/bin/*; do
    b=`basename $file`
    ln -s /usr/share/%name-%version/bin/$b %{buildroot}/usr/bin/$b
    echo "/usr/bin/$b" >> %{_topdir}/files
done

%files -f %{_topdir}/files

%changelog
* Wed Apr 17 2019 vagrant
- 
