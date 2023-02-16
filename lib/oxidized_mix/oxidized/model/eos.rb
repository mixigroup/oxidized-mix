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

# Modified copy of https://github.com/ytti/oxidized/blob/0.28.0/lib/oxidized/model/eos.rb
class EOS < Oxidized::Model
  # Arista EOS model #

  prompt(/^.+[#>]\s?$/)

  comment '! '

  cmd :all do |cfg| # rubocop:disable Style/SymbolProc
    cfg.cut_both
  end

  cmd :secret do |cfg|
    cfg.gsub!(/^(snmp-server community).*/, '\\1 <configuration removed>')
    cfg.gsub!(/(secret \w+) (\S+).*/, '\\1 <secret hidden>')
    cfg.gsub!(/(password \d+) (\S+).*/, '\\1 <secret hidden>')
    cfg.gsub!(/^(enable secret).*/, '\\1 <configuration removed>')
    cfg.gsub!(/^(tacacs-server key \d+).*/, '\\1 <configuration removed>')
    cfg.gsub!(/( {6}key) (\h+ 7) (\h+).*/, '\\1 <secret hidden>')
    cfg
  end

  cmd 'show version | no-more' do |cfg|
    cfg = "Model: #{cfg}"
    cfg.gsub!(/^(Uptime:) .*/, '\\1 <masked>')
    cfg.gsub!(/^(Free memory:) .*/, '\\1 <masked>')
    comment cfg
  end

  cmd 'show inventory | no-more' do |cfg|
    comment cfg
  end

  cmd 'show running-config | no-more | exclude ! Time:' do |cfg|
    cfg
  end

  cfg :telnet, :ssh do
    if vars :enable
      post_login do
        send "enable\n"
        # Interpret enable: true as meaning we won't be prompted for a password
        unless vars(:enable).is_a? TrueClass
          expect(/[pP]assword:\s?$/)
          send "#{vars(:enable)}\n"
        end
        expect(/^.+[#>]\s?$/)
      end
      post_login 'terminal length 0'
    end
    pre_logout 'exit'
  end
end
