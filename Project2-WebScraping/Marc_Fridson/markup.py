<th scope="row" class="right " data-stat="ranker" csk="1" >1</th>
<td class="left " data-append-csv="baker-mayfield-1" data-stat="player" csk="Mayfield,Baker" ><a href="/cfb/players/baker-mayfield-1.html">Baker Mayfield</a></td>
<td class="left " data-stat="school_name" csk="Oklahoma.Mayfield,Baker" ><a href="/cfb/schools/oklahoma/2016.html">Oklahoma</a></td>
<td class="left " data-stat="conf_abbr" csk="Big 12 Conference.Mayfield,Baker" ><a href="/cfb/conferences/big-12/2016.html">Big 12</a></td>
<td class="right " data-stat="g" >13</td>
<td class="right " data-stat="pass_cmp" >254</td>
<td class="right " data-stat="pass_att" >358</td>
<td class="right " data-stat="pass_cmp_pct" >70.9</td><td class="right " data-stat="pass_yds" >3965</td>
<td class="right " data-stat="pass_yds_per_att" >11.1</td>
<td class="right " data-stat="adj_pass_yds_per_att" >12.3</td><td class="right " data-stat="pass_td" >40</td>
<td class="right " data-stat="pass_int" >8</td>
<td class="right " data-stat="pass_rating" >196.4</td>
<td class="right " data-stat="rush_att" >78</td>
<td class="right " data-stat="rush_yds" >177</td>
<td class="right " data-stat="rush_yds_per_att" >2.3</td>
<td class="right " data-stat="rush_td" >6</td></tr>

col=table.findAll('th' or 'td')

def find_between( s):
    try:
        start = s.index( '>' ) + len( '>' )
        end = s.index( '</', '>' )
        return s[start:end]
    except ValueError:
        return ""