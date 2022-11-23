{
  activesupport = {
    dependencies = ["concurrent-ruby" "i18n" "minitest" "tzinfo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vybx4cj42hr6m8cdwbrqq2idh98zms8c11kr399xjczhl9ywjbj";
      type = "gem";
    };
    version = "5.2.6";
  };
  backports = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cczfi1yp7a68bg7ipzi4lvrmi4xsi36n9a19krr4yb3nfwd8fn2";
      type = "gem";
    };
    version = "3.15.0";
  };
  better_errors = {
    dependencies = ["coderay" "erubi" "rack"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11220lfzhsyf5fcril3qd689kgg46qlpiiaj00hc9mh4mcbc3vrr";
      type = "gem";
    };
    version = "2.9.1";
  };
  browser = {
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cxc50z4a63k8f3vlr6kwfd6y391iwdw5lga0i6bxmh8y622zbcz";
      type = "gem";
    };
    version = "2.6.1";
  };
  chunky_png = {
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "124najs9prqzrzk49h53kap992rmqxj0wni61z2hhsn7mwmgdp9d";
      type = "gem";
    };
    version = "1.3.11";
  };
  coderay = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
      type = "gem";
    };
    version = "1.1.3";
  };
  coffee-script = {
    dependencies = ["coffee-script-source" "execjs"];
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rc7scyk7mnpfxqv5yy4y5q1hx3i7q3ahplcp4bq2g5r24g2izl2";
      type = "gem";
    };
    version = "2.4.1";
  };
  coffee-script-source = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1907v9q1zcqmmyqzhzych5l7qifgls2rlbnbhy5vzyr7i7yicaz1";
      type = "gem";
    };
    version = "1.12.2";
  };
  concurrent-ruby = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nwad3211p7yv9sda31jmbyw6sdafzmdi2i2niaz6f0wk5nq9h0f";
      type = "gem";
    };
    version = "1.1.9";
  };
  daemons = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fki1aipqafqlg8xy25ykk0ql1dciy9kk6lcp5gzgkh9ccmaxzf3";
      type = "gem";
    };
    version = "1.4.0";
  };
  erubi = {
    groups = ["app" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09l8lz3j00m898li0yfsnb6ihc63rdvhw3k5xczna5zrjk104f2l";
      type = "gem";
    };
    version = "1.10.0";
  };
  ethon = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gggrgkcq839mamx7a8jbnp2h7x2ykfn34ixwskwb0lzx2ak17g9";
      type = "gem";
    };
    version = "0.12.0";
  };
  eventmachine = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      type = "gem";
    };
    version = "1.2.7";
  };
  execjs = {
    groups = ["app" "default" "production"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yz55sf2nd3l666ms6xr18sm2aggcvmb8qr3v53lr4rir32y1yp1";
      type = "gem";
    };
    version = "2.7.0";
  };
  exifr = {
    groups = ["app" "default"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "rbx";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q2abhiyvgfv23i0izbskjxcqaxiw9bfg6s57qgn4li4yxqpwpfg";
      type = "gem";
    };
    version = "1.3.6";
  };
  ffi = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1862ydmclzy1a0cjbvm8dz7847d9rch495ib0zb64y84d3xd4bkg";
      type = "gem";
    };
    version = "1.15.5";
  };
  fspath = {
    groups = ["app" "default"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "rbx";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xcxikkrjv8ws328nn5ax5pyfjs8pn7djg1hks7qyb3yp6prpb5m";
      type = "gem";
    };
    version = "3.1.2";
  };
  highline = {
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yclf57n2j3cw8144ania99h1zinf8q3f5zrhqa754j6gl95rp9d";
      type = "gem";
    };
    version = "2.0.3";
  };
  html-pipeline = {
    dependencies = ["activesupport" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f7x70p3fda7i5wfjjljjgjgqwx8m12345bs4xpnh7fhnis42fkk";
      type = "gem";
    };
    version = "2.12.0";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g2fnag935zn2ggm5cn6k4s4xvv53v2givj1j90szmvavlpya96a";
      type = "gem";
    };
    version = "1.8.10";
  };
  image_optim = {
    dependencies = ["exifr" "fspath" "image_size" "in_threads" "progress"];
    groups = ["app"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "rbx";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bscz93kmhf87zgb9cmw4z96adxl45472aylv7pfh9977lwkqp59";
      type = "gem";
    };
    version = "0.26.5";
  };
  image_optim_pack = {
    dependencies = ["fspath" "image_optim"];
    groups = ["app"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "rbx";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vymv2lnir1yicnih6fcgxgg8znji9xxgvxyzrji5pamqyng1pa1";
      type = "gem";
    };
    version = "0.6.0";
  };
  image_size = {
    groups = ["app" "default"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "rbx";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ixghy1qlp7sci47zdrm5rwwdhvvb0hnyw3r1lmgc6fxzp4v8xpl";
      type = "gem";
    };
    version = "2.0.2";
  };
  in_threads = {
    groups = ["app" "default"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "rbx";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vd1kqz333q9a9j6nji52py2gjv1cklp7hpmff6cvjz49s9w96ig";
      type = "gem";
    };
    version = "1.5.3";
  };
  method_source = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pnyh44qycnf9mzi1j6fywd5fkskv3x7nmsqrrws0rjn5dd4ayfp";
      type = "gem";
    };
    version = "1.0.0";
  };
  mini_portile2 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rapl1sfmfi3bfr68da4ca16yhc0pp93vjwkj7y3rdqrzy3b41hy";
      type = "gem";
    };
    version = "2.8.0";
  };
  minitest = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19z7wkhg59y8abginfrm2wzplz7py3va8fyngiigngqvsws6cwgl";
      type = "gem";
    };
    version = "5.14.4";
  };
  multi_json = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rl0qy4inf1mp8mybfk56dfga0mvx97zwpmq5xmiwl5r770171nv";
      type = "gem";
    };
    version = "1.13.1";
  };
  mustermann = {
    dependencies = ["ruby2_keywords"];
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ccm54qgshr1lq3pr1dfh7gphkilc19dp63rw6fcx7460pjwy88a";
      type = "gem";
    };
    version = "1.1.1";
  };
  net-sftp = {
    dependencies = ["net-ssh"];
    groups = ["docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h0gipdrcndf6nfxqxc5faf6qxa72avy76nyb3y30q8545db3db2";
      type = "gem";
    };
    version = "3.0.0.beta1";
  };
  net-ssh = {
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "101wd2px9lady54aqmkibvy4j62zk32w0rjz4vnigyg974fsga40";
      type = "gem";
    };
    version = "5.2.0";
  };
  newrelic_rpm = {
    groups = ["production"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pnpxiiyxkssmndjy5q55bgh694kikd0jw9d1awgfrbcx8xszh21";
      type = "gem";
    };
    version = "6.7.0.359";
  };
  nokogiri = {
    dependencies = ["mini_portile2" "racc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11w59ga9324yx6339dgsflz3dsqq2mky1qqdwcg6wi5s1bf2yldi";
      type = "gem";
    };
    version = "1.13.6";
  };
  options = {
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s650nwnabx66w584m1cyw82icyym6hv5kzfsbp38cinkr5klh9j";
      type = "gem";
    };
    version = "2.3.2";
  };
  progress = {
    groups = ["app" "default"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "rbx";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pm3bv5n8c8j0vfm7wghd7xf6yq4m068cksxjldmna11qi0h0s8s";
      type = "gem";
    };
    version = "3.5.2";
  };
  progress_bar = {
    dependencies = ["highline" "options"];
    groups = ["docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06l5mrs98830mrvmcy7m2kd7ij2ci84q642wphq0rhzr15vysrlm";
      type = "gem";
    };
    version = "1.3.0";
  };
  pry = {
    dependencies = ["coderay" "method_source"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0m445x8fwcjdyv2bc0glzss2nbm1ll51bq45knixapc7cl3dzdlr";
      type = "gem";
    };
    version = "0.14.1";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0la56m0z26j3mfn1a9lf2l03qx1xifanndf9p3vx1azf6sqy7v9d";
      type = "gem";
    };
    version = "1.6.0";
  };
  rack = {
    groups = ["app" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b1qsg0yfargdhmpapp2d3mlxj82wyygs9nj74w0r03diyi8swlc";
      type = "gem";
    };
    version = "2.2.3.1";
  };
  rack-protection = {
    dependencies = ["rack"];
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xcvf6lxwdfls6mk1pc6kyw37gr9jyyal83vc6cnlscyp7zafh8j";
      type = "gem";
    };
    version = "2.0.7";
  };
  rack-ssl-enforcer = {
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "020i3fbii76g1b5jhc6va4zb13br0r2q5jzfpd3cms6is58l1vwr";
      type = "gem";
    };
    version = "0.2.9";
  };
  rack-test = {
    dependencies = ["rack"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rh8h376mx71ci5yklnpqqn118z3bl67nnv5k801qaqn1zs62h8m";
      type = "gem";
    };
    version = "1.1.0";
  };
  rake = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05l80mgaabdipkjsnjlffn9gc1wx9fi629d2kfbz8628cx3m6686";
      type = "gem";
    };
    version = "13.0.0";
  };
  rb-fsevent = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lm1k7wpz69jx7jrc92w3ggczkjyjbfziq5mg62vjnxmzs383xx8";
      type = "gem";
    };
    version = "0.10.3";
  };
  rb-inotify = {
    dependencies = ["ffi"];
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fs7hxm9g6ywv2yih83b879klhc4fs8i0p9166z795qmd77dk0a4";
      type = "gem";
    };
    version = "0.10.0";
  };
  rr = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n9g78ba4c2zzmz8cdb97c38h1xm0clircag00vbcxwqs4dq0ymp";
      type = "gem";
    };
    version = "1.2.1";
  };
  ruby2_keywords = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
      type = "gem";
    };
    version = "0.0.5";
  };
  sass = {
    dependencies = ["sass-listen"];
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0p95lhs0jza5l7hqci1isflxakz83xkj97lkvxl919is0lwhv2w0";
      type = "gem";
    };
    version = "3.7.4";
  };
  sass-listen = {
    dependencies = ["rb-fsevent" "rb-inotify"];
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xw3q46cmahkgyldid5hwyiwacp590zj2vmswlll68ryvmvcp7df";
      type = "gem";
    };
    version = "4.0.0";
  };
  sinatra = {
    dependencies = ["mustermann" "rack" "rack-protection" "tilt"];
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zmi68iv2lsp9lj6vpmwd9grga2v4hsphagjkzqb908v83539jbw";
      type = "gem";
    };
    version = "2.0.7";
  };
  sinatra-contrib = {
    dependencies = ["backports" "multi_json" "mustermann" "rack-protection" "sinatra" "tilt"];
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "026s6z315dahy9j4lkm48hfm07l6b35sdnwn673al997nmvyp5r8";
      type = "gem";
    };
    version = "2.0.7";
  };
  sprockets = {
    dependencies = ["concurrent-ruby" "rack"];
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "182jw5a0fbqah5w9jancvfmjbk88h8bxdbwnl4d3q809rpxdg8ay";
      type = "gem";
    };
    version = "3.7.2";
  };
  sprockets-helpers = {
    dependencies = ["sprockets"];
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08aba0lmhcy3wxbcqqflbbd4garqd0vqvnyk41ilnd78cya0ml1x";
      type = "gem";
    };
    version = "1.2.1";
  };
  sprockets-sass = {
    dependencies = ["sprockets"];
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02g153dhzmrlik5dd9kyq0rvr2xjm3fwx8rm7apqfrykc47aizqr";
      type = "gem";
    };
    version = "2.0.0.beta2";
  };
  strings = {
    dependencies = ["strings-ansi" "unicode-display_width" "unicode_utils"];
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xvafvr0lgkqivvahifq2yd10qvn2jp6jcknjlck79f26i929k82";
      type = "gem";
    };
    version = "0.1.6";
  };
  strings-ansi = {
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jx6zwinaxaaapgbai83dbpgg19gipzmsiqzkpmwwgmigsn6bwiy";
      type = "gem";
    };
    version = "0.1.0";
  };
  terminal-table = {
    dependencies = ["unicode-display_width"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1512cngw35hsmhvw4c05rscihc59mnj09m249sm9p3pik831ydqk";
      type = "gem";
    };
    version = "1.8.0";
  };
  thin = {
    dependencies = ["daemons" "eventmachine" "rack"];
    groups = ["app"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "123bh7qlv6shk8bg8cjc84ix8bhlfcilwnn3iy6zq3l57yaplm9l";
      type = "gem";
    };
    version = "1.8.1";
  };
  thor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yhrnp9x8qcy5vc7g438amd5j9sw83ih7c30dr6g6slgw9zj3g29";
      type = "gem";
    };
    version = "0.20.3";
  };
  thread_safe = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  tilt = {
    groups = ["app" "default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rn8z8hda4h41a64l0zhkiwz2vxw9b1nb70gl37h1dg2k874yrlv";
      type = "gem";
    };
    version = "2.0.10";
  };
  tty-pager = {
    dependencies = ["strings" "tty-screen" "tty-which"];
    groups = ["docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06gn2fcaa6p25j1sx3g0ifsp1ddhdz846xq5l13x4vfvq8zxvfa2";
      type = "gem";
    };
    version = "0.12.1";
  };
  tty-screen = {
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1143g05fs28ssgimaph6sdnsndd1wrpax9kjypvd2ripa1adm4kx";
      type = "gem";
    };
    version = "0.7.0";
  };
  tty-which = {
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0akipq0czg2jz050cvgfipg060b3cjhk7wm33frd78x3p4ck5z1i";
      type = "gem";
    };
    version = "0.4.1";
  };
  typhoeus = {
    dependencies = ["ethon"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cni8b1idcp0dk8kybmxydadhfpaj3lbs99w5kjibv8bsmip2zi5";
      type = "gem";
    };
    version = "1.3.1";
  };
  tzinfo = {
    dependencies = ["thread_safe"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rw89y3zj0wcybcyiazgcprg6hi42k8ipp1n2lbl95z1dmpgmly6";
      type = "gem";
    };
    version = "1.2.10";
  };
  uglifier = {
    dependencies = ["execjs"];
    groups = ["production"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wgh7bzy68vhv9v68061519dd8samcy8sazzz0w3k8kqpy3g4s5f";
      type = "gem";
    };
    version = "4.2.0";
  };
  unicode-display_width = {
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08kfiniak1pvg3gn5k6snpigzvhvhyg7slmm0s2qx5zkj62c1z2w";
      type = "gem";
    };
    version = "1.6.0";
  };
  unicode_utils = {
    groups = ["default" "docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h1a5yvrxzlf0lxxa1ya31jcizslf774arnsd89vgdhk4g7x08mr";
      type = "gem";
    };
    version = "1.4.0";
  };
  unix_utils = {
    groups = ["docs"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "134ii02ig7x77lwpw8lgmaaizzkp3g60r85dia72ha19hbd9xj71";
      type = "gem";
    };
    version = "0.0.15";
  };
  yajl-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lni4jbyrlph7sz8y49q84pb0sbj82lgwvnjnsiv01xf26f4v5wc";
      type = "gem";
    };
    version = "1.4.3";
  };
}
