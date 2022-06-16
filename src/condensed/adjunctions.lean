import algebra.category.Group.adjunctions
import category_theory.sites.adjunction
import category_theory.sites.left_exact
import algebra.category.Group.abelian
import algebra.category.Group.filtered_colimits

import for_mathlib.SheafOfTypes_sheafification
import for_mathlib.whisker_adjunction
import for_mathlib.abelian_sheaves.exact
import for_mathlib.abelian_sheaves.main
import for_mathlib.AddCommGroup

import condensed.basic

universe u

open category_theory category_theory.limits

noncomputable theory

@[simps obj map]
def CondensedSet_to_presheaf : CondensedSet ⥤ Profiniteᵒᵖ ⥤ Type* :=
Sheaf_to_presheaf _ _

@[simps obj_val map]
def presheaf_to_CondensedSet : (Profiniteᵒᵖ ⥤ Type*) ⥤ CondensedSet :=
presheaf_to_Sheaf _ _

def CondensedSet_presheaf_adjunction : presheaf_to_CondensedSet ⊣ CondensedSet_to_presheaf :=
sheafification_adjunction proetale_topology (Type (u+1))

@[simp]
lemma CondensedSet_presheaf_adjunction_hom_equiv_apply (X : Profiniteᵒᵖ ⥤ Type*)
  (Y : CondensedSet) (e : presheaf_to_CondensedSet.obj X ⟶ Y) :
  CondensedSet_presheaf_adjunction.hom_equiv _ _ e =
  proetale_topology.to_sheafify X ≫ e.val := rfl

@[simp]
lemma CondensedSet_presheaf_adjunction_hom_equiv_symm_apply (X : Profiniteᵒᵖ ⥤ Type*)
  (Y : CondensedSet) (e : X ⟶ CondensedSet_to_presheaf.obj Y) :
  ((CondensedSet_presheaf_adjunction.hom_equiv _ _).symm e).val =
  proetale_topology.sheafify_lift e Y.cond := rfl

@[simp]
lemma CondensedSet_presheaf_adjunction_unit_app (X : Profiniteᵒᵖ ⥤ Type*) :
  CondensedSet_presheaf_adjunction.unit.app X =
  proetale_topology.to_sheafify X := rfl

@[simp]
lemma CondensedSet_presheaf_adjunction_counit_app (Y : CondensedSet) :
  (CondensedSet_presheaf_adjunction.counit.app Y).val =
  proetale_topology.sheafify_lift (𝟙 _) Y.cond := rfl

@[simps obj_val map]
def Condensed_Ab_to_CondensedSet : Condensed Ab ⥤ CondensedSet :=
Sheaf_compose _ (forget _)

@[simps obj_val map]
def CondensedSet_to_Condensed_Ab : CondensedSet ⥤ Condensed Ab :=
Sheaf.compose_and_sheafify _ AddCommGroup.free

@[simps obj_val map]
def CondensedSet_to_Condensed_Ab' : CondensedSet ⥤ Condensed Ab :=
Sheaf.compose_and_sheafify _ AddCommGroup.free'

@[simps hom_app_val inv_app_val]
def CondensedSet_to_Condensed_Ab_iso :
  CondensedSet_to_Condensed_Ab ≅ CondensedSet_to_Condensed_Ab' :=
iso_whisker_left _ $ iso_whisker_right (functor.map_iso _ $ AddCommGroup.free_iso_free') _

@[simps unit_app counit_app]
def Condensed_Ab_CondensedSet_adjunction :
  CondensedSet_to_Condensed_Ab ⊣ Condensed_Ab_to_CondensedSet :=
Sheaf.adjunction _ AddCommGroup.adj

@[simps unit_app counit_app]
def Condensed_Ab_CondensedSet_adjunction' :
  CondensedSet_to_Condensed_Ab' ⊣ Condensed_Ab_to_CondensedSet :=
Sheaf.adjunction _ AddCommGroup.adj'

@[simp]
lemma Condensed_Ab_CondensedSet_adjunction_hom_equiv_apply (X : CondensedSet)
  (Y : Condensed Ab) (e : CondensedSet_to_Condensed_Ab.obj X ⟶ Y) :
  (Condensed_Ab_CondensedSet_adjunction.hom_equiv _ _ e).val =
  (AddCommGroup.adj.whisker_right _).hom_equiv _ _ (proetale_topology.to_sheafify _ ≫ e.val) := rfl

@[simp]
lemma Condensed_Ab_CondensedSet_adjunction_hom_equiv_symm_apply (X : CondensedSet)
  (Y : Condensed Ab) (e : X ⟶ Condensed_Ab_to_CondensedSet.obj Y) :
  ((Condensed_Ab_CondensedSet_adjunction.hom_equiv _ _).symm e).val =
  proetale_topology.sheafify_lift
    (((AddCommGroup.adj.whisker_right _).hom_equiv _ _).symm e.val) Y.2 := rfl

@[simp]
lemma Condensed_Ab_CondensedSet_adjunction'_hom_equiv_apply (X : CondensedSet)
  (Y : Condensed Ab) (e : CondensedSet_to_Condensed_Ab'.obj X ⟶ Y) :
  (Condensed_Ab_CondensedSet_adjunction'.hom_equiv _ _ e).val =
  (AddCommGroup.adj'.whisker_right _).hom_equiv _ _ (proetale_topology.to_sheafify _ ≫ e.val) := rfl

@[simp]
lemma Condensed_Ab_CondensedSet_adjunction'_hom_equiv_symm_apply (X : CondensedSet)
  (Y : Condensed Ab) (e : X ⟶ Condensed_Ab_to_CondensedSet.obj Y) :
  ((Condensed_Ab_CondensedSet_adjunction'.hom_equiv _ _).symm e).val =
  proetale_topology.sheafify_lift
    (((AddCommGroup.adj'.whisker_right _).hom_equiv _ _).symm e.val) Y.2 := rfl

def presheaf_to_Condensed_Ab :
  (Profinite.{u}ᵒᵖ ⥤ Ab.{u+1}) ⥤ Condensed.{u} Ab.{u+1} :=
presheaf_to_Sheaf _ _

def Condensed_Ab_to_presheaf :
  Condensed.{u} Ab.{u+1} ⥤ Profinite.{u}ᵒᵖ ⥤ Ab.{u+1} :=
Sheaf_to_presheaf _ _

def Condensed_Ab_presheaf_adjunction :
  presheaf_to_Condensed_Ab.{u} ⊣ Condensed_Ab_to_presheaf.{u} :=
sheafification_adjunction _ _

instance presheaf_to_Condensed_Ab_preserves_colimits :
  preserves_colimits presheaf_to_Condensed_Ab.{u} :=
Condensed_Ab_presheaf_adjunction.left_adjoint_preserves_colimits

set_option pp.universes true

instance : functor.additive presheaf_to_Condensed_Ab.{u} :=
by apply category_theory.Sheaf.presheaf_to_Sheaf_additive.{u+2 u u+1}

instance : functor.additive Condensed_Ab_to_presheaf := ⟨⟩

instance : preserves_colimits presheaf_to_Condensed_Ab :=
Condensed_Ab_presheaf_adjunction.left_adjoint_preserves_colimits

instance : preserves_finite_limits presheaf_to_Condensed_Ab :=
category_theory.presheaf_to_Sheaf.limits.preserves_finite_limits.{u+2 u u+1}
