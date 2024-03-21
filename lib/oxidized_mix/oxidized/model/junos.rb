#--
# Copyright (c) 2023 MIXI, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# ---
#
# This is derived from material copyright
#   2013-2015 Saku Ytti <saku@ytti.fi>
#   2013-2015 Samer Abdel-Hafez <sam@arahant.net>
#
#   Licensed under the Apache License, Version 2.0 (the "License"); you may not use
#   this file except in compliance with the License. You may obtain a copy of the
#   License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
#++

# Modified copy of https://github.com/ytti/oxidized/blob/0.28.0/lib/oxidized/model/junos.rb
class JunOS < Oxidized::Model
  using Refinements

  comment '# '

  def telnet
    @input.class.to_s.match(/Telnet/)
  end

  cmd :all do |cfg|
    cfg = cfg.cut_both if screenscrape
    cfg.gsub!(/  scale-subscriber (\s+)(\d+)/, '  scale-subscriber                <count>')
    cfg.lines.map(&:rstrip).join("\n") << "\n"
  end

  cmd :secret do |cfg|
    cfg.gsub!(/community (\S+) {/, 'community <hidden> {')
    cfg.gsub!(/ "\$\d\$\S+; ## SECRET-DATA/, ' <secret removed>;')
    cfg
  end

  cmd 'show version' do |cfg|
    @model = Regexp.last_match(1) if cfg =~ /^Model: (\S+)/
    comment cfg
  end

  post do
    out = ''
    case @model
    when 'mx960'
      out << cmd('show chassis fabric reachability') { |cfg| comment cfg }
    when /^(ex22|ex33|ex4|ex8|qfx)/
      out << cmd('show virtual-chassis') { |cfg| comment cfg }
    end
    out
  end

  cmd('show chassis hardware detail') { |cfg| comment cfg }
  cmd('show system license') { |cfg| comment cfg }
  cmd('show system license keys') { |cfg| comment cfg }

  cmd 'show configuration | display set'

  cfg :telnet do
    username(/^login:/)
    password(/^Password:/)
  end

  cfg :ssh do
    exec true # don't run shell, run each command in exec channel
  end

  cfg :telnet, :ssh do
    post_login 'set cli screen-length 0'
    post_login 'set cli screen-width 0'
    pre_logout 'exit'
  end
end
