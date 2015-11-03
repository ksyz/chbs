%global commit0 4bdee9019a942afbbb9c176cd05bd72ba6398ab3
%global shortcommit0 %(c=%{commit0}; echo ${c:0:7})
%global package_name chbs

Name:           perl-Acme-CHBS
Version:        2
Release:        1%{?dist}
Summary:        Correct horse battery staple
License:        WTFPL
Group:          Development/Libraries
URL:            https://github.com/ksyz/chbs
Source0:        https://github.com/ksyz/%{package_name}/archive/%{commit0}.tar.gz#/%{package_name}-%{shortcommit0}.tar.gz
Source1:        https://world.std.com/~reinhold/diceware8k.txt
BuildArch:      noarch
Requires:       perl(Crypt::Random::TESHA2)
Requires:       perl(File::Slurp)
Requires:       words
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Another xkcd-936 inspired, correct horse battery staple password 
generator.

%prep
%setup -q -n chbs-%{commit0}
echo %{SOURCE1}

%build

%install
install -d -m755 %{buildroot}%{perl_vendorlib}/Acme
install -m644 lib/Acme/CHBS.pm %{buildroot}%{perl_vendorlib}/Acme

install -d -m755 %{buildroot}%{_bindir}
install -m755 chbs %{buildroot}%{_bindir}/chbs
install -m755 dwgen %{buildroot}%{_bindir}/dwgen

install -d -m755 %{buildroot}%{_datadir}/dict/
install -m644 %{SOURCE1} %{buildroot}%{_datadir}/dict/

%{_fixperms} %{buildroot}

%files
%{perl_vendorlib}/*
%{_bindir}/*
%{_datadir}/*
%doc README.md

%changelog
* Mon Nov  3 2015 Michal Ingeli <mi@v3.sk> 2-1
- New release
- Release numbering with one integer increments, from now on.

* Mon Nov  2 2015 Michal Ingeli <mi@v3.sk> 1.1-1
- New release

* Mon Nov  2 2015 Michal Ingeli <mi@v3.sk> 1.0-1
- Initial package.
