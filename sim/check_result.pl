#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::Path qw(make_path);

# 确保RES目录存在
my $res_dir = 'RES';
make_path($res_dir) unless -d $res_dir;

# 打开结果文件
open my $out_fh, '>', "$res_dir/result.log" or die "无法创建结果文件: $!";

# 递归遍历log目录
find({
    wanted => sub {
        return unless -f $_ && /\.log$/;  # 只处理.log文件
        my $file = $File::Find::name;

        open my $in_fh, '<', $file or do {
            warn "无法打开 $file: $!";
            return;
        };

        my $has_fail = 0;
        while (<$in_fh>) {
            if (/FAIL/) {
                $has_fail = 1;
                last;  # 发现FAIL立即停止读取
            }
        }
        close $in_fh;

        # 无FAIL则写入结果
        print $out_fh "$file: PASS\n" unless $has_fail;
    },
    no_chdir => 1
}, 'log');  # 从log目录开始遍历

close $out_fh;
print "检查完成！结果已保存到 $res_dir/result.log\n";