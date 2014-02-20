/***************************************************************************
 *  eval_game_points_for_2014.js - Evaluation for LLSF RefBox Database
 *
 *  Created: Thu Feb 20 15:47:23 2014
 *  Copyright  2014  Tim Niemueller [www.niemueller.de]
 ****************************************************************************/

/*  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in
 *   the documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the authors nor the names of its contributors
 *   may be used to endorse or promote products derived from this
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* This script can be run on a LLSF RefBox database to evaluate the number
 * of maximum points with respect to the way we want to set the maximum
 * points in 2014, i.e. 20 points for production and delivery from a T3/T4
 * and 10 for delivery from a T5.
 *
 * USAGE: mongo eval_game_points_for_2014.js
 */


var DBNAME = "llsfrb";

conn = new Mongo();
db = conn.getDB(DBNAME);

function emit_productions()
{
    if (this.points.length == 0) {
	var rv = {_id: this._id, team: this.team, productions: {NONE: 0}};
	emit(this._id, rv);
    }
    for (var i = 0; i < this.points.length; ++i) {
	//print(this.points[i].reason);
	matches = this.points[i].reason.match(/^([^ ]*) production.*$/);
	if (matches) {
	    var rv = {_id: this._id, team: this.team, productions: {}};
	    rv.productions[matches[1]] = 1;
	    //printjson(rv);
	    emit(this._id, rv);
	}
    };
}

function reduce_productions(key, values)
{
    rv = values[0];
    for (var i = 1; i < values.length; ++i) {
	for (var key in values[i].productions) {
	    if (key in rv.productions) {
		rv.productions[key] += values[i].productions[key];
	    } else {
		rv.productions[key]  = values[i].productions[key];
	    }
	}
    }
    return rv; 
}

function pad(width, str)
{
    var out_str = str;
    for (var i = str.length; i < width; ++i)
	out_str += " ";
    return out_str;
}

var res = db.game_report.mapReduce(emit_productions, reduce_productions, {out: {inline: 1}});

//printjson(res);
var max_value = 0;
var best_team = "?";
var best_prod = "?";

var avg_value = 0;
var avg_count = 0;

var med_values = [];

for (var i = 0; i < res.results.length; ++i) {
    var str = "";
    var value = 0;
    for (key in res.results[i].value.productions) {
	str += " "+ key + ":" + res.results[i].value.productions[key];
	if (key == "T3" || key == "T4")
	    value += res.results[i].value.productions[key] * 20;
	else if (key == "T5")
	    value += res.results[i].value.productions[key] * 10;
    }
    if (value > max_value) {
	max_value = value;
	best_team = res.results[i].value.team;
	best_prod = str;
    }
    if (value > 0) {
	avg_value += value;
	avg_count += 1;
	med_values.push(value);
    }
    //print(pad(18, res.results[i].value.team) + pad(30, str) + "VALUE: " + value);
}

avg_value /= avg_count;
med_values.sort();


print("Database:        " + DBNAME);
print("Number of games: " + res.results.length);
print("Non-zero games:  " + avg_count);
print("Average value:   " + avg_value);
print("Median value:    " + med_values[~~(avg_count / 2)]);
print("Maximum value:   " + max_value);
print("Best Team:       " + best_team);
print("Best Production:" + best_prod);
