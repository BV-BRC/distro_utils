%global _python_bytecompile_extra 0
%global debug_package %{nil}

Name:           %name
Version:        %version
Release:        2%{?dist}
Summary:        The PATRIC Command Line Interface

License:        MIT
URL:            https://patricbrc.org/
Source0:        %source

BuildRequires:  perl-Template-Toolkit perl-File-Slurp perl-Path-Tiny perl-local-lib
Requires:       perl

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
     --override KB_OVERRIDE_PERL_PATH=/usr/share/%name-%version/lib:/usr/share/%name-%version/local/lib \
     --override KB_OVERRIDE_PYTHON_PATH=/usr/share/%name-%version/lib \
      deploy.cfg

%files
/usr/share/%name-%version


%changelog
* Wed Apr 17 2019 vagrant
- 
