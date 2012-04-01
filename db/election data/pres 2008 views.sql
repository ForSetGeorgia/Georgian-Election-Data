DROP VIEW IF EXISTS `2008 pres - precincts`;
CREATE VIEW `2008 pres - precincts`
AS select
   `2008 pres - raw`.`Region` AS `Region`,
   `2008 pres - raw`.`district_Name` AS `district_Name`,
   `2008 pres - raw`.`district_id` AS `district_id`,
   `2008 pres - raw`.`precinct_id` AS `precinct_id`,
   `2008 pres - raw`.`final_turnout_12__P6a_` AS `votes 8-12`,
   (`2008 pres - raw`.`final_turnout_17__P6b_` - `2008 pres - raw`.`final_turnout_12__P6a_`) AS `votes 12-17`,
   (`2008 pres - raw`.`final_signature_total__P7_` - `2008 pres - raw`.`final_turnout_17__P6b_`) AS `votes 17-18`,
   (`2008 pres - raw`.`final_turnout_12__P6a_` / 240) AS `vpm 8-12`,
   ((`2008 pres - raw`.`final_turnout_17__P6b_` - `2008 pres - raw`.`final_turnout_12__P6a_`) / 300) AS `vpm 12-17`,
   ((`2008 pres - raw`.`final_signature_total__P7_` - `2008 pres - raw`.`final_turnout_17__P6b_`) / 180) AS `vpm 17-20`,
   `2008 pres - raw`.`final_signature_total__P7_` AS `total ballots cast`,
   `2008 pres - raw`.`final_ballots_valid__P11_` AS `total valid ballots cast`,
   `2008 pres - raw`.`Levan Gachechiladze` AS `Levan Gachechiladze`,
   100*(`2008 pres - raw`.`Levan Gachechiladze` / `2008 pres - raw`.`final_ballots_valid__P11_`) AS `Levan Gachechiladze vote share`,
   `2008 pres - raw`.`Arkadi (Badri) Patarkatsishvili` AS `Arkadi (Badri) Patarkatsishvili`,
   100*(`2008 pres - raw`.`Arkadi (Badri) Patarkatsishvili` / `2008 pres - raw`.`final_ballots_valid__P11_`) AS `Arkadi (Badri) Patarkatsishvili vote share`,
   `2008 pres - raw`.`Davit Gamkrelidze` AS `Davit Gamkrelidze`,
   100*(`2008 pres - raw`.`Davit Gamkrelidze` / `2008 pres - raw`.`final_ballots_valid__P11_`) AS `Davit Gamkrelidze vote share`,
   `2008 pres - raw`.`Shalva Natelashvili` AS `Shalva Natelashvili`,
   100*(`2008 pres - raw`.`Shalva Natelashvili` / `2008 pres - raw`.`final_ballots_valid__P11_`) AS `Shalva Natelashvili vote share`,
   `2008 pres - raw`.`Mikheil Saakashvili` AS `Mikheil Saakashvili`,
   100*(`2008 pres - raw`.`Mikheil Saakashvili` / `2008 pres - raw`.`final_ballots_valid__P11_`) AS `Mikheil Saakashvili vote share`,
   `2008 pres - raw`.`Giorgi (Gia) Maisashvili` AS `Giorgi (Gia) Maisashvili`,
   100*(`2008 pres - raw`.`Giorgi (Gia) Maisashvili` / `2008 pres - raw`.`final_ballots_valid__P11_`) AS `Giorgi (Gia) Maisashvili vote share`,
   `2008 pres - raw`.`Irina Sarishvili-Chanturia` AS `Irina Sarishvili-Chanturia`,
   100*(`2008 pres - raw`.`Irina Sarishvili-Chanturia` / `2008 pres - raw`.`final_ballots_valid__P11_`) AS `Irina Sarishvili-Chanturia vote share`
from `2008 pres - raw`;

DROP VIEW IF EXISTS `2008 pres - districts`;
CREATE VIEW `2008 pres - districts`
AS select
   `2008 pres - raw`.`Region` AS `Region`,
   `2008 pres - raw`.`district_Name` AS `district_Name`,
   `2008 pres - raw`.`district_id` AS `district_id`,
   sum(`2008 pres - raw`.`final_turnout_12__P6a_`) AS `votes 8-12`,
   sum((`2008 pres - raw`.`final_turnout_17__P6b_` - `2008 pres - raw`.`final_turnout_12__P6a_`)) AS `votes 12-17`,
   sum((`2008 pres - raw`.`final_signature_total__P7_` - `2008 pres - raw`.`final_turnout_17__P6b_`)) AS `votes 17-18`,
   (sum(`2008 pres - raw`.`final_turnout_12__P6a_`) / 240) AS `vpm 8-12`,
   (sum((`2008 pres - raw`.`final_turnout_17__P6b_` - `2008 pres - raw`.`final_turnout_12__P6a_`)) / 300) AS `vpm 12-17`,
   (sum((`2008 pres - raw`.`final_signature_total__P7_` - `2008 pres - raw`.`final_turnout_17__P6b_`)) / 180) AS `vpm 17-20`,
   sum(`2008 pres - raw`.`final_signature_total__P7_`) AS `total ballots cast`,
   sum(`2008 pres - raw`.`final_ballots_valid__P11_`) AS `total valid ballots cast`,
   sum(`2008 pres - raw`.`Levan Gachechiladze`) AS `Levan Gachechiladze`,
   100*(sum(`2008 pres - raw`.`Levan Gachechiladze`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Levan Gachechiladze vote share`,
   sum(`2008 pres - raw`.`Arkadi (Badri) Patarkatsishvili`) AS `Arkadi (Badri) Patarkatsishvili`,
   100*(sum(`2008 pres - raw`.`Arkadi (Badri) Patarkatsishvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Arkadi (Badri) Patarkatsishvili vote share`,
   sum(`2008 pres - raw`.`Davit Gamkrelidze`) AS `Davit Gamkrelidze`,
   100*(sum(`2008 pres - raw`.`Davit Gamkrelidze`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Davit Gamkrelidze vote share`,
   sum(`2008 pres - raw`.`Shalva Natelashvili`) AS `Shalva Natelashvili`,
   100*(sum(`2008 pres - raw`.`Shalva Natelashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Shalva Natelashvili vote share`,
   sum(`2008 pres - raw`.`Mikheil Saakashvili`) AS `Mikheil Saakashvili`,
   100*(sum(`2008 pres - raw`.`Mikheil Saakashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Mikheil Saakashvili vote share`,
   sum(`2008 pres - raw`.`Giorgi (Gia) Maisashvili`) AS `Giorgi (Gia) Maisashvili`,
   100*(sum(`2008 pres - raw`.`Giorgi (Gia) Maisashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Giorgi (Gia) Maisashvili vote share`,
   sum(`2008 pres - raw`.`Irina Sarishvili-Chanturia`) AS `Irina Sarishvili-Chanturia`,
   100*(sum(`2008 pres - raw`.`Irina Sarishvili-Chanturia`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Irina Sarishvili-Chanturia vote share`
from `2008 pres - raw` 
group by `2008 pres - raw`.`Region`,`2008 pres - raw`.`district_Name`,`2008 pres - raw`.`district_id`;

DROP VIEW IF EXISTS `2008 pres - regions`;
CREATE VIEW `2008 pres - regions`
AS select
   `2008 pres - raw`.`Region` AS `Region`,
   sum(`2008 pres - raw`.`final_turnout_12__P6a_`) AS `votes 8-12`,
   sum((`2008 pres - raw`.`final_turnout_17__P6b_` - `2008 pres - raw`.`final_turnout_12__P6a_`)) AS `votes 12-17`,
   sum((`2008 pres - raw`.`final_signature_total__P7_` - `2008 pres - raw`.`final_turnout_17__P6b_`)) AS `votes 17-18`,
   (sum(`2008 pres - raw`.`final_turnout_12__P6a_`) / 240) AS `vpm 8-12`,
   (sum((`2008 pres - raw`.`final_turnout_17__P6b_` - `2008 pres - raw`.`final_turnout_12__P6a_`)) / 300) AS `vpm 12-17`,
   (sum((`2008 pres - raw`.`final_signature_total__P7_` - `2008 pres - raw`.`final_turnout_17__P6b_`)) / 180) AS `vpm 17-20`,
   sum(`2008 pres - raw`.`final_signature_total__P7_`) AS `total ballots cast`,
   sum(`2008 pres - raw`.`final_ballots_valid__P11_`) AS `total valid ballots cast`,
   sum(`2008 pres - raw`.`Levan Gachechiladze`) AS `Levan Gachechiladze`,
   100*(sum(`2008 pres - raw`.`Levan Gachechiladze`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Levan Gachechiladze vote share`,
   sum(`2008 pres - raw`.`Arkadi (Badri) Patarkatsishvili`) AS `Arkadi (Badri) Patarkatsishvili`,
   100*(sum(`2008 pres - raw`.`Arkadi (Badri) Patarkatsishvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Arkadi (Badri) Patarkatsishvili vote share`,
   sum(`2008 pres - raw`.`Davit Gamkrelidze`) AS `Davit Gamkrelidze`,
   100*(sum(`2008 pres - raw`.`Davit Gamkrelidze`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Davit Gamkrelidze vote share`,
   sum(`2008 pres - raw`.`Shalva Natelashvili`) AS `Shalva Natelashvili`,
   100*(sum(`2008 pres - raw`.`Shalva Natelashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Shalva Natelashvili vote share`,
   sum(`2008 pres - raw`.`Mikheil Saakashvili`) AS `Mikheil Saakashvili`,
   100*(sum(`2008 pres - raw`.`Mikheil Saakashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Mikheil Saakashvili vote share`,
   sum(`2008 pres - raw`.`Giorgi (Gia) Maisashvili`) AS `Giorgi (Gia) Maisashvili`,
   100*(sum(`2008 pres - raw`.`Giorgi (Gia) Maisashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Giorgi (Gia) Maisashvili vote share`,
   sum(`2008 pres - raw`.`Irina Sarishvili-Chanturia`) AS `Irina Sarishvili-Chanturia`,
   100*(sum(`2008 pres - raw`.`Irina Sarishvili-Chanturia`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Irina Sarishvili-Chanturia vote share`
from `2008 pres - raw` 
group by `2008 pres - raw`.`Region`;

DROP VIEW IF EXISTS `2008 pres - country`;
CREATE VIEW `2008 pres - country`
AS select
   sum(`2008 pres - raw`.`final_turnout_12__P6a_`) AS `votes 8-12`,
   sum((`2008 pres - raw`.`final_turnout_17__P6b_` - `2008 pres - raw`.`final_turnout_12__P6a_`)) AS `votes 12-17`,
   sum((`2008 pres - raw`.`final_signature_total__P7_` - `2008 pres - raw`.`final_turnout_17__P6b_`)) AS `votes 17-18`,
   (sum(`2008 pres - raw`.`final_turnout_12__P6a_`) / 240) AS `vpm 8-12`,
   (sum((`2008 pres - raw`.`final_turnout_17__P6b_` - `2008 pres - raw`.`final_turnout_12__P6a_`)) / 300) AS `vpm 12-17`,
   (sum((`2008 pres - raw`.`final_signature_total__P7_` - `2008 pres - raw`.`final_turnout_17__P6b_`)) / 180) AS `vpm 17-20`,
   sum(`2008 pres - raw`.`final_signature_total__P7_`) AS `total ballots cast`,
   sum(`2008 pres - raw`.`final_ballots_valid__P11_`) AS `total valid ballots cast`,
   sum(`2008 pres - raw`.`Levan Gachechiladze`) AS `Levan Gachechiladze`,
   100*(sum(`2008 pres - raw`.`Levan Gachechiladze`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Levan Gachechiladze vote share`,
   sum(`2008 pres - raw`.`Arkadi (Badri) Patarkatsishvili`) AS `Arkadi (Badri) Patarkatsishvili`,
   100*(sum(`2008 pres - raw`.`Arkadi (Badri) Patarkatsishvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Arkadi (Badri) Patarkatsishvili vote share`,
   sum(`2008 pres - raw`.`Davit Gamkrelidze`) AS `Davit Gamkrelidze`,
   100*(sum(`2008 pres - raw`.`Davit Gamkrelidze`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Davit Gamkrelidze vote share`,
   sum(`2008 pres - raw`.`Shalva Natelashvili`) AS `Shalva Natelashvili`,
   100*(sum(`2008 pres - raw`.`Shalva Natelashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Shalva Natelashvili vote share`,
   sum(`2008 pres - raw`.`Mikheil Saakashvili`) AS `Mikheil Saakashvili`,
   100*(sum(`2008 pres - raw`.`Mikheil Saakashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Mikheil Saakashvili vote share`,
   sum(`2008 pres - raw`.`Giorgi (Gia) Maisashvili`) AS `Giorgi (Gia) Maisashvili`,
   100*(sum(`2008 pres - raw`.`Giorgi (Gia) Maisashvili`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Giorgi (Gia) Maisashvili vote share`,
   sum(`2008 pres - raw`.`Irina Sarishvili-Chanturia`) AS `Irina Sarishvili-Chanturia`,
   100*(sum(`2008 pres - raw`.`Irina Sarishvili-Chanturia`) / sum(`2008 pres - raw`.`final_ballots_valid__P11_`)) AS `Irina Sarishvili-Chanturia vote share`
from `2008 pres - raw` ;