use strict;
use File::Basename ('basename', 'dirname');
use File::Copy ('copy', 'move');

my $program = "generate";
my $version = "0.2";
my $mod_date = "2021/01/21";
my $project = "fontworksfree";
my $map_file = "../pdfm-$project.map";
my $pmap_file = "../$project.map";
my $sty_file = "../tex/$project.sty";
my $tfm_dir = "../tfm";
my $ofm_dir = "../ofm";
my $vf_dir = "../vf";
my $tex_dir = "../tex";
my $pkgns = "bxqff";
my $pltotf = "uppltotf";
my $pxacid = "pxacid";
my $jfmutil = "jfmutil";

my $tempb = '__gen';
chdir(dirname($0));

my @encoding = qw( jy1 jy2 jt1 jt2 );
my %wgtname = (
  r => 'Regular', b => 'Semibold'
);
my %wgtser = (
  r => 'm', b => 'bx'
);
my %cmapname = (
  jy1 => 'H', jy2 => 'UniJIS-UTF16-H',
  jt1 => 'V', jt2 => 'UniJIS-UTF16-V',
);

my (@map_line, @pmap_line, @sty_chunk);

sub main {
  preprocess();
  gen_family('dotgothic16',  'DotGothic16',  9353,  'r');
  gen_family('kleeone',      'KleeOne',      15443, 'r', 'b');
  gen_family('rampartone',   'RampartOne',   9353,  'r');
  gen_family('reggaeone',    'ReggaeOne',    9353,  'r');
  gen_family('rocknrollone', 'RocknRollOne', 9353,  'r');
  gen_family('stick',        'Stick',        9353,  'r');
  gen_family('trainone',     'TrainOne',     4089,  'r');
  postprocess();
}

sub gen_family {
  my ($fam, $pfam, $mgid, @pwgt) = @_; local ($_);
  my ($N, $SCL) = map { "\\$pkgns\@$_" } (qw(N scl));
  push(@map_line, "% family '$pfam'");
  push(@pmap_line, "% family '$pfam'");
  push(@sty_chunk, <<"EOT");
%% family '$pfam'
\\ifptex
\\DeclareFontFamily{JY$N}{$fam}{}
\\DeclareFontFamily{JT$N}{$fam}{}
EOT

  my ($bwgt, $cyc) = (0, 0);
  foreach my $wgt (@pwgt) {
    my $pbas = "$fam-" . $wgtname{$wgt};
    if ($wgt eq 'b') { $bwgt = 1; }
    my $ser = $wgtser{$wgt};
    push(@sty_chunk, <<"EOT");
\\DeclareFontShape{JY$N}{$fam}{$ser}{n}{<->$SCL $fam-$wgt-jy$N}{}
\\DeclareFontShape{JT$N}{$fam}{$ser}{n}{<->$SCL $fam-$wgt-jt$N}{}
EOT
    foreach (qw(it sl)) { push(@sty_chunk, <<"EOT"); }
\\DeclareFontShape{JY$N}{$fam}{$ser}{$_}{<->ssub*$fam/$ser/n}{}
\\DeclareFontShape{JT$N}{$fam}{$ser}{$_}{<->ssub*$fam/$ser/n}{}
EOT

    foreach my $enc (@encoding) {
      my $cmap = $cmapname{$enc};
      my @to = ("$fam-$wgt-$enc", "r-$fam-$wgt-$enc");
      if ($enc eq 'jy2') { push(@to, "r-$fam-$wgt-jy1"); }
      run("$jfmutil vfcopy !gen-$enc @to");
      push(@map_line, "r-$fam-$wgt-$enc $cmap $pbas.ttf");
    }

    my $aopt = ($cyc > 0) ? '-a' : '';
    run("$pxacid $aopt --no-italic --gid-max=$mgid --adjust-accent=0.5 " .
        "--tfm-family=$fam a$fam/$ser $pbas.ttf");

    foreach (glob("$fam-$wgt*.tfm"), glob("r-$fam-$wgt*.tfm")) {
      move($_, "$tfm_dir/$_");
    }
    foreach (glob("$fam-$wgt*.ofm")) {
      move($_, "$ofm_dir/$_");
    }
    foreach (glob("$fam-$wgt*.vf")) {
      move($_, "$vf_dir/$_");
    }

    $cyc += 1;
  }

  my $amap = read_pxacid_map("pdfm-a$fam.map");
  push(@map_line, @$amap);

  foreach (glob("*$fam.fd")) {
    move($_, "$tex_dir/$_");
  }
  unlink(glob("pxacid-test-a$fam-*.tex"));
  unlink("pdfm-a$fam.map", "pxacid-a$fam.sty");

  if (!$bwgt) {
    foreach (qw(n it sl)) { push(@sty_chunk, <<"EOT"); }
\\DeclareFontShape{JY$N}{$fam}{bx}{$_}{<->ssub*$fam/m/$_}{}
\\DeclareFontShape{JT$N}{$fam}{bx}{$_}{<->ssub*$fam/m/$_}{}
EOT
  }
  foreach (qw(n it sl)) { push(@sty_chunk, <<"EOT"); }
\\DeclareFontShape{JY$N}{$fam}{b}{$_}{<->ssub*$fam/bx/$_}{}
\\DeclareFontShape{JT$N}{$fam}{b}{$_}{<->ssub*$fam/bx/$_}{}
EOT
  push(@sty_chunk, <<"EOT");
\\DeclareRobustCommand*{\\j${fam}family}{%
  \\not\@math\@alphabet\\j${fam}family\\relax\\kanjifamily{$fam}\\selectfont}
\\DeclareRobustCommand*{\\a${fam}family}{%
  \\not\@math\@alphabet\\a${fam}family\\relax\\romanfamily{a$fam}\\selectfont}
\\DeclareRobustCommand*{\\${fam}family}{%
  \\not\@math\@alphabet\\${fam}family\\relax
  \\kanjifamily{$fam}\\romanfamily{a$fam}\\selectfont}
\\else
\\DeclareRobustCommand*{\\${fam}family}{%
  \\not\@math\@alphabet\\${fam}family\\relax\\fontfamily{a$fam}\\selectfont}
\\fi
EOT
}
sub preprocess {
  make_dir($tfm_dir, $ofm_dir, $vf_dir, $tex_dir);
  foreach my $enc (@encoding) {
    run("$pltotf r-!gen-$enc r-!gen-$enc");
    run("$jfmutil zvp2vf !gen-$enc");
  }
  my $date = $mod_date; $date =~ s|-|/|g;
  my $pkg = nxbase($sty_file);
  my $pmap = nxbase($pmap_file);
  my $map = nxbase($map_file);
  push(@map_line, "% $map.map");
  push(@pmap_line, "% $pmap.map");
  push(@sty_chunk, <<"EOT");
% This is file '$pkg.sty'.

%% package declaration
\\NeedsTeXFormat{LaTeX2e}
\\ProvidesPackage{$project}[$date v$version]

%--------------------------------------- preparations

\\RequirePackage{iftex,ifpdf,ifptex}
\\if \\ifpdf T\\else\\ifXeTeX T\\else\\ifLuaTeX T\\else F\\fi\\fi\\fi T%
  \\PackageError{$project}
   {The engine in use is not supported}
   {Package loading is aborted.}
\\expandafter\\endinput\\fi\\relax
\\AtBeginDvi{\\special{pdf:mapfile $map.map}}
\\ifptex
  \\edef\\$pkgns\@N{\\ifuptex 2\\else 1\\fi}
  \\let\\$pkgns\@scl\\\@empty
  \\begingroup
    \\dimen\@=\\ifx\\Cjascale\\\@undefined\\else\\Cjascale\\fi\\p\@
    \\ifuptex\\else \\dimen\@=1.03927\\dimen\@ \\fi
    \\ifdim\\dimen\@=\\p\@ \\else
      \\xdef\\$pkgns\@scl{s*[\\strip\@pt\\dimen\@]}
    \\fi
  \\endgroup
\\fi

%--------------------------------------- font declarations
EOT
}

sub postprocess {
  push(@map_line, "%% EOF\n");
  write_whole($map_file, join("\n", @map_line));
  push(@pmap_line, "%% EOF\n");
  # write_whole($pmap_file, join("\n", @pmap_line));
  push(@sty_chunk, <<"EOT");

%--------------------------------------- done
\\endinput
%% EOF
EOT
  write_whole($sty_file, join("", @sty_chunk));
  unlink(glob("$tempb*.*"));
  unlink(glob("!gen-*.tfm"), glob("!gen-*.vf"), glob("r-!gen-*.tfm"));
}

sub read_pxacid_map {
  my ($fmap) = @_; local ($_); my (@cs);
  open(my $h, '<', $fmap) or error("cannot open for read", $fmap);
  while (<$h>) {
    s/\#.*//; s/\s+$//; s/^\s+//; (m/^\w/) or next;
    push(@cs, $_);
  }
  close($h);
  return \@cs;
}

sub info {
  print STDERR (join(": ", $program, @_), "\n");
}
sub error {
  info(@_); exit(1);
}

sub write_whole {
  my ($path, $text) = @_;
  open(my $h, '>', $path) or error("cannot open for write", $path);
  binmode($h);
  print $h ($text);
  close($h);
}

sub make_dir {
  foreach my $dir (@_) {
    mkdir($dir);
    (-d $dir) or error("cannot make directory", $dir);
    unlink(glob("$dir/*.*"));
  }
}

sub nxbase {
  my ($p) = @_;
  local $_ = basename($p); s/\.\w+$//;
  return $_;
}

sub run {
  info("run", "@_");
  system(@_);
  ($? == 0) or error("failure", "@_");
}

main();
