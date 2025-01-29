InconjunctionsMaker {
    value { |durations, divisions, groupSizes, pitches, hairpins, articulations, finalize|
        var maker, selections, selection;

        maker = FoscMusicMaker();
        selections = [];

        groupSizes.do { |sizes, i|
            selection = maker.(durations: durations, divisions: divisions);
            
            selection.logicalTies.partitionBySizes(sizes).do { |group|
                if (group.size > 1) {
                    group.beam;
                    if (hairpins.notNil) { group.hairpin(hairpins.wrapAt(i)) };
                };

                if (articulations.notNil) {
                    articulations.do { |each| group.leafAt(0).attach(FoscArticulation(each)) };
                };

                if (pitches.notNil) { mutate(group).rewritePitches(pitches.wrapAt(i)) };
            };

            #[
                // lilypond formatting
                "\\accidentalStyle dodecaphonic",
                "\\override Stem.direction = #DOWN",
                "\\override TupletBracket.direction = #UP"
            ].do { |str| selection[0].attach(FoscLilyPondLiteral(str)) };

            selections = selections.add(selection);
        };

        selections.do { |each, i| finalize.(each, i) };

        ^selections;
    }
}
