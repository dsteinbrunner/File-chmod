  $VERSION @ISA @EXPORT @EXPORT_OK $DEBUG
  $UMASK $MASK $VAL $W $MODE
$VERSION = '0.32';
  EDETMOD => "use of determine_mode is deprecated",
  ENEXLOC => "cannot set group execute on locked file",
  ENLOCEX => "cannot set file locking on group executable file",
  ENSGLOC => "cannot set-gid on locked file",
  ENLOCSG => "cannot set file locking on set-gid file",
  ENEXUID => "execute bit must be on for set-uid",
  ENEXGID => "execute bit must be on for set-gid",
  ENULSID => "set-id has no effect for 'others'",
  ENULSBG => "sticky bit has no effect for 'group'",
  ENULSBO => "sticky bit has no effect for 'others'",
  my @return = map { (stat)[2] & 07777 } @_;
  return wantarray ? @return : $return[0];
  my $mode = shift;
  my $how = mode($mode);
  return symchmod($mode,@_) if $how == $SYM;
  return lschmod($mode,@_) if $how == $LS;
  return CORE::chmod($mode,@_);
  my $mode = shift;
  my $how = mode($mode);
  return getsymchmod($mode,@_) if $how == $SYM;
  return getlschmod($mode,@_) if $how == $LS;
  return wantarray ? (($mode) x @_) : $mode;
  my $mode = shift;
  my @return = getsymchmod($mode,@_);
  my $ret = 0;
  for (@_){ $ret++ if CORE::chmod(shift(@return),$_) }
  return $ret;
  my $mode = shift;
  my @return;

  croak "symchmod received non-symbolic mode: $mode" if mode($mode) != $SYM;

  for (@_){
    local $VAL = getmod($_);

    for my $this (split /,/, $mode){
      local $W = 0;
      my $or;

      for (split //, $this){
        if (not defined $or and /[augo]/){
          /a/ and $W |= 7, next;
          /u/ and $W |= 1, next;
          /g/ and $W |= 2, next;
          /o/ and $W |= 4, next;
        }

        if (/[-+=]/){
          $W ||= 7;
          $or = (/[=+]/ ? 1 : 0);
          clear() if /=/;
          next;
        }

        croak "Bad mode $this" if not defined $or;
        croak "Unknown mode: $mode" if !/[ugorwxslt]/;

        /u/ and $or ? u_or() : u_not();
        /g/ and $or ? g_or() : g_not();
        /o/ and $or ? o_or() : o_not();
        /r/ and $or ? r_or() : r_not();
        /w/ and $or ? w_or() : w_not();
        /x/ and $or ? x_or() : x_not();
        /s/ and $or ? s_or() : s_not();
        /l/ and $or ? l_or() : l_not();
        /t/ and $or ? t_or() : t_not();
      }
    }
    $VAL &= ~$MASK if $UMASK;
    push @return, $VAL;
  }
  return wantarray ? @return : $return[0];
  my $mode = shift;
  return CORE::chmod(getlschmod($mode,@_),@_);
}
sub getlschmod {
  my $mode = shift;
  my $VAL = 0;
  croak "lschmod received non-ls mode: $mode" if mode($mode) != $LS;
  my ($u,$g,$o) = ($mode =~ /^.(...)(...)(...)$/);
  for ($u){
    $VAL |= 0400 if /r/;
    $VAL |= 0200 if /w/;
    $VAL |= 0100 if /[xs]/;
    $VAL |= 04000 if /[sS]/;
  }

  for ($g){
    $VAL |= 0040 if /r/;
    $VAL |= 0020 if /w/;
    $VAL |= 0010 if /[xs]/;
    $VAL |= 02000 if /[sS]/;
  }

  for ($o){
    $VAL |= 0004 if /r/;
    $VAL |= 0002 if /w/;
    $VAL |= 0001 if /[xt]/;
    $VAL |= 01000 if /[Tt]/;
  }

  return wantarray ? (($VAL) x @_) : $VAL;
  my $mode = shift;
  return 0 if $mode !~ /\D/;
  return $SYM if $mode =~ /[augo=+,]/;
  return $LS if $mode =~ /^.([r-][w-][xSs-]){2}[r-][w-][xTt-]$/;
  return $SYM;
  warn $ERROR{EDECMOD};
  mode(@_);
  $W & 1 and $VAL &= 02077;
  $W & 2 and $VAL &= 05707;
  $W & 4 and $VAL &= 07770;
  
  my $val = $VAL;
  $W & 2 and ($VAL |= (($val & 0700)>>3 | ($val & 04000)>>1));
  $W & 4 and ($VAL |= (($val & 0700)>>6));
  my $val = $VAL;
  $W & 1 and $VAL &= ~(($val & 0700) | ($val & 05000));
  $W & 2 and $VAL &= ~(($val & 0700)>>3 | ($val & 04000)>>1);
  $W & 4 and $VAL &= ~(($val & 0700)>>6);
  my $val = $VAL;
  $W & 1 and $VAL |= (($val & 070)<<3 | ($val & 02000)<<1);
  $W & 4 and $VAL |= ($val & 070)>>3;
  my $val = $VAL;
  $W & 1 and $VAL &= ~(($val & 070)<<3 | ($val & 02000)<<1);
  $W & 2 and $VAL &= ~(($val & 070) | ($val & 02000));
  $W & 4 and $VAL &= ~(($val & 070)>>3);
  my $val = $VAL;
  $W & 1 and $VAL |= (($val & 07)<<6);
  $W & 2 and $VAL |= (($val & 07)<<3);
  my $val = $VAL;
  $W & 1 and $VAL &= ~(($val & 07)<<6);
  $W & 2 and $VAL &= ~(($val & 07)<<3);
  $W & 4 and $VAL &= ~($val & 07);
  $W & 1 and $VAL |= 0400;
  $W & 2 and $VAL |= 0040;
  $W & 4 and $VAL |= 0004;
  $W & 1 and $VAL &= ~0400;
  $W & 2 and $VAL &= ~0040;
  $W & 4 and $VAL &= ~0004;
  $W & 1 and $VAL |= 0200;
  $W & 2 and $VAL |= 0020;
  $W & 4 and $VAL |= 0002;
  $W & 1 and $VAL &= ~0200;
  $W & 2 and $VAL &= ~0020;
  $W & 4 and $VAL &= ~0002;
  if ($VAL & 02000){ $DEBUG and warn($ERROR{ENEXLOC}), return }
  $W & 1 and $VAL |= 0100;
  $W & 2 and $VAL |= 0010;
  $W & 4 and $VAL |= 0001;
  $W & 1 and $VAL &= ~0100;
  $W & 2 and $VAL &= ~0010;
  $W & 4 and $VAL &= ~0001;
  if ($VAL & 02000){ $DEBUG and warn($ERROR{ENSGLOC}), return }
  if (not $VAL & 00100){ $DEBUG and warn($ERROR{ENEXUID}), return }
  if (not $VAL & 00010){ $DEBUG and warn($ERROR{ENEXGID}), return }
  $W & 1 and $VAL |= 04000;
  $W & 2 and $VAL |= 02000;
  $W & 4 and $DEBUG and warn $ERROR{ENULSID};
  $W & 1 and $VAL &= ~04000;
  $W & 2 and $VAL &= ~02000;
  $W & 4 and $DEBUG and warn $ERROR{ENULSID};
  if ($VAL & 02010){ $DEBUG and warn($ERROR{ENLOCSG}), return }
  if ($VAL & 00010){ $DEBUG and warn($ERROR{ENLOCEX}), return }
  $VAL |= 02000;
  $VAL &= ~02000 if not $VAL & 00010;
  $W & 1 and $VAL |= 01000;
  $W & 2 and $DEBUG and warn $ERROR{ENULSBG};
  $W & 4 and $DEBUG and warn $ERROR{ENULSBO};
  $W & 1 and $VAL &= ~01000;
  $W & 2 and $DEBUG and warn $ERROR{ENULSBG};
  $W & 4 and $DEBUG and warn $ERROR{ENULSBO};
This is File::chmod v0.32.
If set to a true value, it will report warnings, similar to those produced
error.  If not, you are not warned of the conflict.  It is set to 1 as
=head2 0.31 to 0.32

=over 4

=item B<license added>

I added a license to this module so that it can be used places without asking
my permission.  Sorry, Adam.

=back

=head2 0.30 to 0.31

=over 4

=item B<fixed getsymchmod() bug>

Whoa.  getsymchmod() was doing some crazy ish.  That's about all I can say.
I did a great deal of debugging, and fixed it up.  It ALL had to do with two
things:

  $or = (/+=/ ? 1 : 0); # should have been /[+=]/

  /u/ && $ok ? u_or() : u_not(); # should have been /u/ and $ok

=item B<fixed getmod() bug>

I was using map() incorrectly in getmod().  Fixed that.

=item B<condensed lschmod()>

I shorted it up, getting rid a variable.

=back

Certain calls to warn() were not guarded by the $DEBUG variable, and now they
    $DEBUG && warn("execute bit must be on for set-uid"); 1;
Jeff C<japhy> Pinyan, F<japhy.734+CPAN@gmail.com>, CPAN ID: PINYAN
=head1 COPYRIGHT AND LICENCE

Copyright (C) 2007 by Jeff Pinyan

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.
