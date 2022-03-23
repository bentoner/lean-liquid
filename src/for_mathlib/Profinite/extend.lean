import topology.category.Profinite.as_limit
import for_mathlib.Fintype

import hacks_and_tricks.asyncI

noncomputable theory

namespace Profinite

open category_theory
open category_theory.limits

universes v u u'

variables {C : Type u} [category.{v} C] (F : Fintype.{v} ⥤ C)
variables {D : Type u'} [category.{v} D]

/-- Change a cone with respect to a morphism from `Profinite`. -/
@[simps]
def change_cone {X Y : Profinite} (f : X ⟶ Y) (D : cone (X.fintype_diagram ⋙ F)) :
  cone (Y.fintype_diagram ⋙ F) :=
{ X := D.X,
  π :=
  { app := λ S, D.π.app (S.comap f.continuous) ≫ F.map (discrete_quotient.map $ le_refl _),
    naturality' := by asyncI {
      rintros I J h,
      dsimp,
      simp only [category.id_comp, category.assoc],
      rw ← D.w (hom_of_le $ discrete_quotient.comap_mono _ $ le_of_hom h),
      simp only [category.assoc, ← F.map_comp, functor.comp_map],
      congr' 2,
      ext ⟨t⟩, refl, } } }
.

-- Assume that C has enough limits.
variable [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ F)]

-- PROJECT: Prove that this is isomorphic to the right Kan extension along `Fintype.to_Profinite`.
/-- Extend a functor `Fintype ⥤ C` to `Profinite`. -/
@[simps]
def extend : Profinite ⥤ C :=
{ obj := λ X, limit (X.fintype_diagram ⋙ F),
  map := λ X Y f, limit.lift _ (change_cone _ f _),
  map_id' := by asyncI {
    intros X,
    ext S,
    dsimp,
    simp only [limit.lift_π, coe_id, change_cone_π_app, limit.cone_π, category.id_comp],
    erw discrete_quotient.map_id,
    change _ ≫ F.map (𝟙 _) = _,
    rw [F.map_id, category.comp_id],
    congr,
    exact S.comap_id, },
  map_comp' := by asyncI {
    intros X Y Z f g,
    ext S,
    dsimp,
    simp only [limit.lift_π, change_cone_π_app,
      limit.cone_π, limit.lift_π_assoc, coe_comp, category.assoc, ← F.map_comp],
    congr,
    exact discrete_quotient.map_comp _ _, } }
.

/-- discrete quotients of a finite type has an initial object given by `⊥`. -/
@[simps]
def bot_initial (X : Fintype) :
  is_initial (⊥ : discrete_quotient (Fintype.to_Profinite.obj X)) :=
{ desc := λ S, hom_of_le bot_le }

/-- The extension of `F : Fintype ⥤ C` extends `F`. -/
@[simps]
def extend_extends : Fintype.to_Profinite ⋙ extend F ≅ F :=
nat_iso.of_components (λ X, begin
  dsimp only [extend, functor.comp_obj],
  let Y := Fintype.to_Profinite.obj X,
  let D := limit.is_limit (Y.fintype_diagram ⋙ F),
  let E := limit_of_diagram_initial (bot_initial X) (Y.fintype_diagram ⋙ F),
  letI : topological_space X := ⊥,
  let e : Fintype.of (⊥ : discrete_quotient X) ≅ X :=
    Fintype.iso_of_equiv (equiv.of_bijective _ (discrete_quotient.proj_bot_bijective)).symm,
  let g := D.cone_point_unique_up_to_iso E,
  exact g ≪≫ F.map_iso e,
end) $
by asyncI {
  intros X Y f,
  letI : topological_space X := ⊥,
  letI : topological_space Y := ⊥,
  have hf : continuous f := continuous_bot,
  let A := Fintype.to_Profinite.obj X,
  let B := Fintype.to_Profinite.obj Y,
  dsimp [is_limit.cone_point_unique_up_to_iso, limit_of_diagram_initial],
  simp only [change_cone_π_app, limit.cone_π, limit.lift_π_assoc, category.assoc],
  let e : (⊥ : discrete_quotient X) ⟶ (⊥ : discrete_quotient Y).comap hf :=
    hom_of_le bot_le,
  erw ← limit.w (A.fintype_diagram ⋙ F) e,
  simp only [category.assoc, ← F.map_comp, functor.comp_map],
  congr' 2,
  simp_rw [← iso.inv_comp_eq, ← category.assoc],
  symmetry,
  rw ← iso.comp_inv_eq,
  refl, }
.

/-
instance extend_preserves_limit (X : Profinite) : preserves_limit X.diagram (extend F) :=
{ preserves := λ D hD,
    let e : X.diagram ⋙ extend F ≅ X.fintype_diagram ⋙ F :=
          iso_whisker_left _ (extend_extends F),
        D' : cone (X.fintype_diagram ⋙ F) :=
          (cones.postcompose e.hom).obj ((extend F).map_cone D) in
  { lift := λ E, begin
      dsimp,
      let D'' : cone X.diagram := X.as_limit_cone,
      let f' : X ⟶ D.X := hD.lift D'',
      admit
    end,
    fac' := _,
    uniq' := _ } }
-/

/-- `extend` is characterized by the fact that it preserves the correct limits and
  that its composition with `Profinite.to_Fintype` is the original functor. -/
def extend_unique (G : Profinite ⥤ C)
  [∀ X : Profinite, preserves_limit X.diagram G]
  (w : Fintype.to_Profinite ⋙ G ≅ F) : G ≅ extend F :=
nat_iso.of_components (λ X,
  let D := (X.as_limit_cone),
      hD := (X.as_limit),
      E := G.map_cone D,
      hE : is_limit E := preserves_limit.preserves hD,
      f : X.diagram ⋙ G ≅ X.fintype_diagram ⋙ F := iso_whisker_left _ w,
      E' : cone (X.fintype_diagram ⋙ F) := (cones.postcompose f.hom).obj E,
      hE' : is_limit E' := (is_limit.postcompose_hom_equiv f _).symm hE in
      hE'.cone_point_unique_up_to_iso (limit.is_limit _) ) $
by asyncI {
  intros A B f,
  dsimp [is_limit.postcompose_hom_equiv, is_limit.of_cone_equiv,
    is_limit.cone_point_unique_up_to_iso],
  ext S,
  simp only [←nat_trans.naturality w.hom, limit.lift_π, cones.postcompose_obj_π,
    functor.comp_map, functor.map_cone_π_app, change_cone_π_app, limit.cone_π,
    limit.lift_π_assoc, whisker_left_app, nat_trans.comp_app, category.assoc],
  simp only [← category.assoc, ← G.map_comp],
  refl, }
.

def extend_commutes
  (G : C ⥤ D)
  [∀ X : Profinite.{v}, preserves_limits_of_shape (discrete_quotient X) G]
  [∀ X : Profinite.{v}, has_limit (X.fintype_diagram ⋙ F ⋙ G)] :
  extend F ⋙ G ≅ extend (F ⋙ G) :=
nat_iso.of_components
(λ X, (is_limit_of_preserves G (limit.is_limit _)).cone_point_unique_up_to_iso (limit.is_limit _)) $
by asyncI {
  intros X Y f,
  ext,
  dsimp,
  simp only [category.assoc, limit.lift_π, change_cone_π_app,
    limit.cone_π, functor.comp_map],
  erw [limit.lift_π, limit.lift_π_assoc],
  dsimp,
  rw [← G.map_comp, limit.lift_π, ← G.map_comp],
  refl, }

/-- A natural transformation induces a natural transformation on extensions. -/
@[simps]
def extend_nat_trans {F G : Fintype ⥤ C}
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ F)]
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ G)]
  (η : F ⟶ G) : extend F ⟶ extend G :=
{ app := λ X, category_theory.limits.lim_map $ whisker_left _ η } .

@[simp]
lemma extend_nat_trans_id (F : Fintype ⥤ C)
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ F)] :
  extend_nat_trans (𝟙 F) = 𝟙 _ :=
begin
  ext S,
  dsimp,
  simp,
end

@[simp]
lemma extend_nat_trans_comp {F G H : Fintype ⥤ C}
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ F)]
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ G)]
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ H)]
  (α : F ⟶ G) (β : G ⟶ H) :
  extend_nat_trans (α ≫ β) = extend_nat_trans α ≫ extend_nat_trans β :=
begin
  ext S,
  dsimp,
  simp,
end

lemma extend_π (F G : Fintype ⥤ C)
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ F)]
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ G)]
  (α : extend F ⟶ extend G) (X : Profinite) (T : discrete_quotient X) :
  α.app X ≫ limit.π _ T =
  (extend F).map (X.as_limit_cone.π.app T) ≫
  α.app (Profinite.of T) ≫ (extend_extends G).hom.app _ :=
begin
  have : (extend_extends G).hom.app (X.fintype_diagram.obj T) =
    limit.π _ ⊥ ≫ _ := rfl,
  erw [this, α.naturality_assoc], congr' 1,
  dsimp [extend],
  simp only [limit.lift_π_assoc, change_cone_π_app, limit.cone_π, category.assoc,
    ← G.map_comp],
  convert (limit.w _ _).symm,
  swap,
  { apply hom_of_le, intros x y h, dsimp [discrete_quotient.comap] at h,
    change _ = _ at h, dsimp [Profinite.as_limit_cone] at h,
    exact quotient.exact' h },
  ext t, rcases t with ⟨t⟩,
  dsimp,
  let E : ↥(X.fintype_diagram.obj T) ≃ (⊥ : discrete_quotient T) :=
    equiv.of_bijective _ discrete_quotient.proj_bot_bijective,
  change E.symm _ = _,
  apply_fun E,
  rw equiv.apply_symm_apply, refl,
end

lemma extend_nat_trans_ext {F G : Fintype ⥤ C}
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ F)]
  [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ G)]
  (α β : extend F ⟶ extend G)
  (h : whisker_left Fintype.to_Profinite α = whisker_left Fintype.to_Profinite β) :
  α = β :=
begin
  ext S T,
  dsimp,
  let p : S ⟶ of T := S.as_limit_cone.π.app T,
  let E : Fintype.to_Profinite ⋙ extend G ≅ G := extend_extends G,
  apply_fun (λ e, (extend F).map p ≫ e.app ⟨T⟩ ≫ E.hom.app _) at h,
  simpa [extend_π] using h,
end

end Profinite
