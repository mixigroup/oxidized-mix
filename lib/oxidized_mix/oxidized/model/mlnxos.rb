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

# Modified copy of https://github.com/ytti/oxidized/blob/0.28.0/lib/oxidized/model/mlnxos.rb
class MLNXOS < Oxidized::Model
  prompt(/([\w.@()-\[:\s\]]+[#>]\s)$/)
  comment '## '

  # Pager Handling
  expect(%r{.+lines\s\d+-\d+(\s|/\d+\s\(END\)\s).+$}) do |data, re|
    send ' '
    data.sub re, ''
  end

  cmd :all do |cfg|
    cfg.gsub!(/\[\?1h\r/, '') # Pager Handling
    cfg.gsub!(/\r\[K/, '') # Pager Handling
    cfg.gsub!(/\s/, '') # Linebreak Handling
    cfg.gsub!(/^CPU load averages:\s.+/, '') # Omit constantly changing CPU info
    cfg.gsub!(/^System memory:\s.+/, '') # Omit constantly changing memory info
    cfg.gsub!(/^Uptime:\s.+/, '') # Omit constantly changing uptime info
    cfg.gsub!(/.+Generated at\s\d+.+/, '') # Omit constantly changing generation time info
    cfg.lines.to_a[2..-3].join
  end

  cmd :secret do |cfg|
    cfg.gsub!(/(snmp-server community).*/, '   <snmp-server community configuration removed>')
    cfg.gsub!(/username (\S+) password (\d+) (\S+).*/, '<secret hidden>')
    cfg
  end

  cmd 'show version' do |cfg|
    comment cfg
  end

  cmd 'show inventory' do |cfg|
    comment cfg
  end

  cmd 'enable'

  cmd 'show running-config expanded' do |cfg|
    cfg.gsub(/ +\n/, "\n")
  end

  cfg :ssh do
    password(/^Password:\s*/)
    pre_logout "\nexit"
  end
end
