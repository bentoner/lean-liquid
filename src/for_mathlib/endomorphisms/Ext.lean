import for_mathlib.endomorphisms.basic
import for_mathlib.derived.les_facts
import for_mathlib.additive_functor

noncomputable theory

universes v u

open category_theory category_theory.limits opposite
open bounded_homotopy_category

namespace homological_complex

variables {𝓐 : Type u} [category.{v} 𝓐] [abelian 𝓐]
variables {ι : Type*} {c : complex_shape ι}

def e (X : homological_complex (endomorphisms 𝓐) c) :
  End (((endomorphisms.forget 𝓐).map_homological_complex c).obj X) :=
{ f := λ i, (X.X i).e,
  comm' := λ i j hij, (X.d i j).comm }

end homological_complex

namespace homotopy_category

variables {𝓐 : Type u} [category.{v} 𝓐] [abelian 𝓐]
variables {𝓑 : Type*} [category 𝓑] [abelian 𝓑]
variables (F : 𝓐 ⥤ 𝓑) [functor.additive F]

instance map_homotopy_category_is_bounded_above
  (X : homotopy_category 𝓐 $ complex_shape.up ℤ) [X.is_bounded_above] :
  ((F.map_homotopy_category _).obj X).is_bounded_above :=
begin
  obtain ⟨b, hb⟩ := is_bounded_above.cond X,
  exact ⟨⟨b, λ i hi, category_theory.functor.map_is_zero _ (hb i hi)⟩⟩,
 end

end homotopy_category

namespace bounded_homotopy_category

variables {𝓐 : Type u} [category.{v} 𝓐] [abelian 𝓐]
variables [has_coproducts_of_shape (ulift.{v} ℕ) 𝓐]
variables [has_products_of_shape (ulift.{v} ℕ) 𝓐]

variables (X : bounded_homotopy_category (endomorphisms 𝓐))

/-- `unEnd` is the "forget the endomorphism" map from the category whose objects are complexes
of pairs `(Aⁱ,eⁱ)` with morphisms defined up to homotopy, to the category whose objects are
complexes of objects `Aⁱ` with morphisms defined up to homotopy.  -/
def unEnd : bounded_homotopy_category 𝓐 :=
of $ ((endomorphisms.forget _).map_homotopy_category _).obj X.val

def e : End X.unEnd := (homotopy_category.quotient _ _).map $ X.val.as.e

end bounded_homotopy_category

namespace category_theory

section
variables {C : Type*} [category C] {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z)

lemma is_iso.comp_right_iff [is_iso g] : is_iso (f ≫ g) ↔ is_iso f :=
begin
  split; introI h,
  { have : is_iso ((f ≫ g) ≫ inv g), { apply_instance },
    simpa only [category.assoc, is_iso.hom_inv_id, category.comp_id] },
  { apply_instance }
end

lemma is_iso.comp_left_iff [is_iso f] : is_iso (f ≫ g) ↔ is_iso g :=
begin
  split; introI h,
  { have : is_iso (inv f ≫ (f ≫ g)), { apply_instance },
    simpa only [category.assoc, is_iso.inv_hom_id_assoc] },
  { apply_instance }
end

end

namespace endomorphisms

variables {𝓐 : Type u} [category.{v} 𝓐] [abelian 𝓐] [enough_projectives 𝓐]
variables [has_coproducts_of_shape (ulift.{v} ℕ) 𝓐]
variables [has_products_of_shape (ulift.{v} ℕ) 𝓐]

def mk_bo_ho_ca (X : bounded_homotopy_category 𝓐) (f : X ⟶ X) :
  bounded_homotopy_category (endomorphisms 𝓐) :=
{ val := { as :=
  { X := λ i, ⟨X.val.as.X i, f.out.f i⟩,
    d := λ i j, ⟨X.val.as.d i j, f.out.comm _ _⟩,
    shape' := λ i j h, by { ext, exact X.val.as.shape i j h, },
    d_comp_d' := λ i j k hij hjk, by { ext, apply homological_complex.d_comp_d } } },
  bdd := begin
    obtain ⟨a, ha⟩ := X.bdd,
    refine ⟨⟨a, λ i hi, _⟩⟩,
    rw is_zero_iff_id_eq_zero, ext, dsimp, rw ← is_zero_iff_id_eq_zero,
    exact ha i hi,
  end }
.

lemma quot_out_single_map {X Y : 𝓐} (f : X ⟶ Y) (i : ℤ) :
  ((homotopy_category.single 𝓐 i).map f).out = (homological_complex.single 𝓐 _ i).map f :=
begin
  have h := homotopy_category.homotopy_out_map
    ((homological_complex.single 𝓐 (complex_shape.up ℤ) i).map f),
  ext k,
  erw h.comm k,
  suffices : (d_next k) h.hom + (prev_d k) h.hom = 0, { rw [this, zero_add] },
  obtain (hki|rfl) := ne_or_eq k i,
  { apply limits.is_zero.eq_of_src,
    show is_zero (ite (k = i) X _), rw [if_neg hki], apply is_zero_zero },
  { have hk1 : (complex_shape.up ℤ).rel (k-1) k := sub_add_cancel _ _,
    have hk2 : (complex_shape.up ℤ).rel k (k+1) := rfl,
    rw [prev_d_eq _ hk1, d_next_eq _ hk2],
    have aux1 : h.hom (k + 1) k = 0,
    { apply limits.is_zero.eq_of_src, show is_zero (ite _ X _), rw if_neg, apply is_zero_zero,
      linarith },
    have aux2 : h.hom k (k - 1) = 0,
    { apply limits.is_zero.eq_of_tgt, show is_zero (ite _ Y _), rw if_neg, apply is_zero_zero,
      linarith },
    rw [aux1, aux2, comp_zero, zero_comp, add_zero], }
end

def mk_bo_ha_ca_single (X : 𝓐) (f : X ⟶ X) :
  mk_bo_ho_ca ((single _ 0).obj X) ((single _ 0).map f) ≅ (single _ 0).obj ⟨X, f⟩ :=
bounded_homotopy_category.mk_iso
begin
  dsimp only [mk_bo_ho_ca, single],
  refine (homotopy_category.quotient _ _).map_iso _,
  refine homological_complex.hom.iso_of_components _ _,
  { intro i,
    refine endomorphisms.mk_iso _ _,
    { dsimp, split_ifs, { exact iso.refl _ },
      { refine (is_zero_zero _).iso _, apply endomorphisms.is_zero_X,
        exact is_zero_zero (endomorphisms 𝓐), } },
    { dsimp, erw quot_out_single_map, dsimp, split_ifs with hi,
      { subst i, dsimp, erw [iso.refl_hom], simp only [category.id_comp, category.comp_id],
        convert rfl, },
      { apply is_zero.eq_of_src, rw [if_neg hi], exact is_zero_zero _ } } },
  { rintro i j (rfl : _ = _),
    by_cases hi : i = 0,
    { apply is_zero.eq_of_tgt, dsimp, rw [if_neg], exact is_zero_zero _, linarith only [hi] },
    { apply is_zero.eq_of_src, dsimp, rw [is_zero_iff_id_eq_zero], ext, dsimp, rw [if_neg hi],
      apply (is_zero_zero _).eq_of_src } }
end

lemma Ext_is_zero_iff (X Y : bounded_homotopy_category (endomorphisms 𝓐)) :
  (∀ i, is_zero (((Ext i).obj (op $ X)).obj $ Y)) ↔
  (∀ i, is_iso $ ((Ext i).map (quiver.hom.op X.e)).app Y.unEnd - ((Ext i).obj (op X.unEnd)).map Y.e) :=
begin
  sorry
end

lemma Ext_is_zero_iff' (X Y : bounded_homotopy_category 𝓐) (f : X ⟶ X) (g : Y ⟶ Y) :
  (∀ i, is_zero (((Ext i).obj (op $ mk_bo_ho_ca X f)).obj $ mk_bo_ho_ca Y g)) ↔
  (∀ i, is_iso $ ((Ext i).map f.op).app Y - ((Ext i).obj (op X)).map g) :=
begin
  rw Ext_is_zero_iff,
  conv_rhs { rw [← homotopy_category.quotient_map_out f, ← homotopy_category.quotient_map_out g] },
  cases X with X hX, cases X with X hX', cases X with X Xd hXs hXd2,
  cases Y with Y hY, cases Y with Y hY', cases Y with Y Yd hYs hYd2,
  dsimp [bounded_homotopy_category.unEnd, bounded_homotopy_category.e,
    mk_bo_ho_ca, functor.map_homological_complex, homological_complex.e,
    homotopy_category.quotient, quotient.functor],
  refl,
end

def single_unEnd (X : endomorphisms 𝓐) : ((single _ 0).obj X).unEnd ≅ (single _ 0).obj X.X :=
sorry
--iso.refl X.X


lemma single_unEnd_e (X : endomorphisms 𝓐) :
  (single_unEnd X).hom ≫ (single _ 0).map X.e = ((single _ 0).obj X).e ≫ (single_unEnd X).hom :=
sorry

lemma single_e (X : endomorphisms 𝓐) :
  (single_unEnd X).hom ≫ (single _ 0).map X.e ≫ (single_unEnd X).inv = ((single _ 0).obj X).e :=
by rw [← category.assoc, iso.comp_inv_eq, single_unEnd_e]

open category_theory.preadditive

lemma Ext'_is_zero_iff (X Y : endomorphisms 𝓐) :
  (∀ i, is_zero (((Ext' i).obj (op X)).obj Y)) ↔
  (∀ i, is_iso $ ((Ext' i).map X.e.op).app Y.X - ((Ext' i).obj (op X.X)).map Y.e) :=
begin
  refine (Ext_is_zero_iff ((single _ 0).obj X) ((single _ 0).obj Y)).trans _,
  apply forall_congr, intro i,
  rw [← single_e X, ← single_e Y],
  rw [← is_iso.comp_left_iff    (((Ext i).obj (op ((single (endomorphisms 𝓐) 0).obj X).unEnd)).map Y.single_unEnd.inv),
      ← is_iso.comp_right_iff _ (((Ext i).obj (op ((single (endomorphisms 𝓐) 0).obj X).unEnd)).map Y.single_unEnd.hom)],
  simp only [nat_trans.comp_app, op_comp, comp_sub, sub_comp,
    category.assoc, nat_trans.naturality, nat_trans.naturality_assoc],
  simp only [← category_theory.functor.map_comp,
    iso.hom_inv_id, iso.inv_hom_id, iso.hom_inv_id_assoc, iso.inv_hom_id_assoc,
    functor.map_id, category.comp_id, category.assoc],
  rw[← is_iso.comp_left_iff    (((Ext i).map X.single_unEnd.hom.op).app ((single 𝓐 0).obj Y.X)),
     ← is_iso.comp_right_iff _ (((Ext i).map X.single_unEnd.inv.op).app ((single 𝓐 0).obj Y.X))],
  simp only [nat_trans.comp_app, op_comp, comp_sub, sub_comp,
    category.assoc, nat_trans.naturality, nat_trans.naturality_assoc],
  simp only [← category_theory.functor.map_comp, ← nat_trans.comp_app, ← op_comp,
    iso.hom_inv_id, iso.inv_hom_id, iso.hom_inv_id_assoc, iso.inv_hom_id_assoc,
    functor.map_id, category.comp_id, category.assoc],
  simp only [← category_theory.functor.map_comp, ← nat_trans.comp_app, ← op_comp,
    iso.hom_inv_id, iso.inv_hom_id, iso.hom_inv_id_assoc, iso.inv_hom_id_assoc,
    functor.map_id, category.id_comp, ← category.assoc, op_id, nat_trans.id_app],
  refl,
end

lemma Ext'_is_zero_iff' (X Y : 𝓐) (f : X ⟶ X) (g : Y ⟶ Y) :
  (∀ i, is_zero (((Ext' i).obj (op $ endomorphisms.mk X f)).obj $ endomorphisms.mk Y g)) ↔
  (∀ i, is_iso $ ((Ext' i).map f.op).app _ - ((Ext' i).obj _).map g) :=
Ext'_is_zero_iff _ _

end endomorphisms

end category_theory
