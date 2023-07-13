-- Table: public.bien

-- DROP TABLE IF EXISTS public.bien;

CREATE TABLE IF NOT EXISTS public.bien
(
    id_bien integer NOT NULL,
    id_codedep_codecommune character varying COLLATE pg_catalog."default" NOT NULL,
    no_voie integer,
    btq character varying(1) COLLATE pg_catalog."default",
    type_voie character varying(4) COLLATE pg_catalog."default",
    voie character varying(50) COLLATE pg_catalog."default",
    total_piece integer,
    surface_carrez double precision,
    surface_local integer,
    type_local character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT bien_pkey PRIMARY KEY (id_bien),
    CONSTRAINT bien_id_codedep_codecommune_fkey FOREIGN KEY (id_codedep_codecommune)
        REFERENCES public.commune (id_codedep_codecommune) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.bien
    OWNER to postgres;
 
 
select * from commune;

select * from region ; 

insert into region ("id_coderegion","nom_region") values (84,'Auvergne-Rhône-Alpes'),
(27,'Bourgogne-Franche-Comté'),(53,'Bretagne'),(24,'Centre-Val-de-Loire'),
(00,'Collectivités-doutre-mer'),(94,'Corse'),(44,'Grand-Est'),
(01,'Guadeloupe'),(03,'Guyane'),(32,'Hauts-de-France'),
(11,'Ile-de-France'),(04,'La-Réunion'),(02,'Martinique'),
(06,'Mayotte'),(28,'Normandie'),(75,'Nouvelle-Aquitaine'),
(76,'Occitanie'),(52,'Pays-de-la-Loire'),(93,'Provence-Alpes-Côte-dAzur'); 
 
 select * from region;
 
 select * from commune;
 
 select * from vente;
 
 select * from bien;
 
--Question 1
select 
      count("id_vente") as Nombre_total_appartements_vendus 
from "vente" 
inner join bien using("id_bien")
where date between '2019/12/31' and '2020/04/01' and type_local='Appartement';
       
--Question 2                
with premier_semestre2020 as (
  select 
         * 
    from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select 
       b_c_r."nom_region",
       count("id_vente") as Nombre_total_appartements_vendus_parRegion
from premier_semestre2020
left join ( select "id_bien","nom_region","type_local" from bien
            left join commune using("id_codedep_codecommune")
            left join region using("id_coderegion")) as b_c_r using(id_bien)
where "type_local"='Appartement'
group by "nom_region"
order by Nombre_total_appartements_vendus_parRegion desc;
          
--Question 3
select 
      count("id_vente")*100/(select count("id_vente") from vente 
      inner join bien using("id_bien") where "type_local"='Appartement' and 
       (date between '2019/12/31' and '2020/04/01') ) as propotion_enourcentage
from vente
inner join bien on vente.id_bien=bien.id_bien
where "type_local"='Appartement' and date between '2019/12/31' and '2020/04/01'
group by "total_piece"
       
--Question 4

with premier_semestre2020 as (
    select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select 
      "code_departement",
      ROUND(("valeur")/("surface_carrez")) as prix_m2
from premier_semestre2020
inner join  bien using("id_bien")
inner join commune using("id_codedep_codecommune")
order by prix_m2 desc
Limit 50;
       
--Question 5
with premier_semestre2020 as (
    select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select 
      avg(("valeur")/("surface_carrez")) as prix_moyen_maison_ilefrance
from premier_semestre2020
left join  bien using("id_bien")
left join commune using("id_codedep_codecommune")
where ("id_coderegion"=11) and (type_local='Maison');
        
--Question 6           
with premier_semestre2020 as (
    select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select 
      b_c_r."nom_region",
      "valeur", b_c_r."surface_carrez" 
from premier_semestre2020
left join ( select "id_bien","nom_region","type_local","surface_carrez" from bien
                  left join commune using("id_codedep_codecommune")
                  left join region using("id_coderegion")) as b_c_r using(id_bien)
where "type_local"='Appartement'
order by "valeur" desc
Limit 20;
          
--Question 7
select 
      cast((-count("id_vente")+(select count("id_vente")
      from vente where date between '2020/03/31' and '2020/07/01'))*100/count("id_vente")
      as float) as taux_croissance
from vente 
where date between '2019/12/31' and '2020/04/01';

--Question 8              
with premier_semestre2020 as (
    select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select  
     b_c_r."nom_region",
     ("valeur")/("surface_carrez") as prix_m2,"total_piece"
from premier_semestre2020
left join ( select "id_bien","nom_region","type_local","surface_carrez","total_piece" from bien
                  left join commune using("id_codedep_codecommune")
                  left join region using("id_coderegion")) as b_c_r using("id_bien")
where ("total_piece">4) and (type_local='Appartement');
        
--Question 9     
with premier_semestre2020 as (
   select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select 
      "nom_commune",
      count("id_vente") as Nombre_vente_commune
from premier_semestre2020
left join  bien using("id_bien")
left join commune using("id_codedep_codecommune")
group by "nom_commune"
having count("id_vente")>=50
order by Nombre_vente_commune desc;

--Question 10 
with premier_semestre2020 as (
    select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select
       (-percentile_disc(.5)within group (order by "valeur")+
       (select percentile_disc(.5)within group(order by "valeur") 
from  premier_semestre2020 inner join bien using("id_bien")
where total_piece=3))*100/avg("valeur")as pourcen_difference23
from premier_semestre2020
inner join bien using("id_bien")
where total_piece=2;

--Question 11 
with premier_semestre2020 as (
  select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select "code_departement","nom_commune",avg("valeur") 
       from premier_semestre2020 
       left join "bien" using("id_bien")
       left join "commune" using("id_codedep_codecommune")
          where "code_departement" in ('6','13','33','59','69')
          group by "code_departement","nom_commune"
          order by "nom_commune" desc;
          
--Question 11 
with premier_semestre2020 as (
    select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select 
      "code_departement","nom_commune",
      avg("valeur") over (partition by "nom_commune") as moyenne
from premier_semestre2020 
left join "bien" using("id_bien")
left join "commune" using("id_codedep_codecommune")
where "code_departement" in ('6','13','33','59','69')
order by moyenne desc;
 
--Question 12  
with premier_semestre2020 as (
    select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select 
      "nom_commune",
      sum("population"),
      count("id_vente") as transaction
from premier_semestre2020 
left join "bien" using("id_bien")
left join "commune" using("id_codedep_codecommune")
group by "nom_commune"
having sum("population")>10000
order by transaction desc
Limit 20
 
--Question 13
select corr("valeur","surface_carrez")
from vente as v
inner join "bien" as b on v.id_bien=b.id_bien 
       
--Question 14
with premier_semestre2020 as (
    select * from vente 
    where date between '2019/12/31' and '2020/04/01'
)
select
       b_c_r."nom_region","type_local",
       case when "valeur"<10000 then 'Très moins couteux'
            when "valeur">1000000 then 'Très luxieux'
            else 'Moyen' end as standing
         ,"valeur" as cout
from premier_semestre2020
inner join ( select "id_bien","nom_region","type_local" from bien
                  inner join commune using("id_codedep_codecommune")
                  inner join region using("id_coderegion")) as b_c_r using(id_bien)
where "type_local"='Appartement'
order by "valeur" desc
       
         
          
