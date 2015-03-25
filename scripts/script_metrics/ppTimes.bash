#!/usr/bin/env bash
perl -lne '$t{$1}=$2 if m/(start|finish).*\+(\d{2}:\d{2})/i; if($t{finish}){@t = map { $b=$_; @a=split/:/; $a[0]*60 + $a[1]} @t{qw/start finish/}; print $t[1]-$t[0] if $t[0]>0 and $t[0]<$t[1]; %t=()  } ' /raid/r5/p1/Luna/Bars/subj/*/bars*/.preprocessfunctional_complete | tee pptimes.txt |  Rio -ne 'summary(df$V1)'

