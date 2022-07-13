import Lbar.ext_aux3
import Lbar.iota

noncomputable theory

universes v u u'

open opposite category_theory category_theory.limits category_theory.preadditive
open_locale nnreal zero_object

variables (r r' : ℝ≥0)
variables [fact (0 < r)] [fact (0 < r')] [fact (r < r')] [fact (r < 1)] [fact (r' < 1)]

open bounded_homotopy_category

variables {r'}
variables (BD : breen_deligne.package)
variables (κ κ₂ : ℝ≥0 → ℕ → ℝ≥0)
variables [∀ (c : ℝ≥0), BD.data.suitable (κ c)] [∀ n, fact (monotone (function.swap κ n))]
variables [∀ (c : ℝ≥0), BD.data.suitable (κ₂ c)] [∀ n, fact (monotone (function.swap κ₂ n))]
variables (M : ProFiltPseuNormGrpWithTinv₁.{u} r')

section preps

variables (V : SemiNormedGroup.{u}) [complete_space V] [separated_space V]
variables (ι : ulift.{u+1} ℕ → ℝ≥0) (hι : monotone ι)

set_option pp.universes true


lemma Tinv2_iso_of_bicartesian_aux_1
  (i : ℤ) : commsq.{u+2 u+1}
  (shift_sub_id.{u+1}
     ((QprimeFP.{u} r' BD.data κ₂ M).op ⋙
        (Ext.{u+1 u+2} i).flip.obj ((single.{u+1 u+2} (Condensed.{u u+1 u+2} Ab.{u+1}) 0).obj V.to_Cond))
     ι
     hι)
  (pi_Ext_iso_Ext_sigma.{u} BD κ₂ M V (λ (k : ulift.{u+1 0} ℕ), ι k) i).hom
  (pi_Ext_iso_Ext_sigma.{u} BD κ₂ M V (λ (k : ulift.{u+1 0} ℕ), ι k) i).hom
  (((Ext.{u+1 u+2} i).map
      (of_hom.{u+1 u+2} (QprimeFP.shift_sub_id.{u u+2 u+1} ι hι (QprimeFP_int.{u} r' BD.data κ₂ M))).op).app
     ((single.{u+1 u+2} (Condensed.{u u+1 u+2} Ab.{u+1}) 0).obj (Condensed.of_top_ab.{u} ↥V))) :=
begin
    apply commsq.of_eq,
    dsimp only [shift_sub_id, QprimeFP.shift_sub_id],
    simp only [sub_comp, comp_sub, homological_complex.of_hom_sub, category_theory.op_sub,
      functor.map_sub, op_id, category_theory.functor.map_id, of_hom_id,
      nat_trans.app_sub, nat_trans.id_app, category.comp_id, category.id_comp],
    apply congr_arg2 _ _ rfl,
    rw ← iso.eq_comp_inv,
    dsimp only [pi_Ext_iso_Ext_sigma, iso.trans_hom, iso.trans_inv,
      iso.symm_hom, iso.symm_inv, functor.map_iso_hom,
      iso.op_hom, op_comp, functor.flip_obj_map, functor.map_iso_inv],
    simp only [category.assoc, ← nat_trans.comp_app_assoc, ← functor.map_comp_assoc,
      ← functor.map_comp, iso.op_inv, ← op_comp],
    rw cofan_point_iso_colimit_conj_eq_desc,
    rw iso.eq_inv_comp,
    have := Ext_coproduct_iso_naturality_shift _
      (λ (k : ulift ℕ), (QprimeFP r' BD.data κ₂ M).obj (ι k))
      (λ k, (QprimeFP r' BD.data κ₂ M).map (hom_of_le $ hι $
        by exact_mod_cast k.down.le_succ)) i ((single (Condensed Ab) 0).obj V.to_Cond),
    exact this.symm,
    sorry,
end

lemma Tinv2_iso_of_bicartesian_aux [normed_with_aut r V]
  [∀ c n, fact (κ₂ c n ≤ κ c n)] [∀ c n, fact (κ₂ c n ≤ r' * κ c n)]
  (i : ℤ)
  (H1 : (shift_sub_id.commsq (ExtQprime.Tinv2 r r' BD.data κ κ₂ M V i) ι hι).bicartesian) :
  (Ext_Tinv2_commsq (of_hom (sigma_map (λ (k : ulift ℕ), ι k) (QprimeFP_int.Tinv BD.data κ₂ κ M)))
  (of_hom (sigma_map (λ (k : ulift ℕ), ι k) (QprimeFP_int.ι BD.data κ₂ κ M)))
  (of_hom (sigma_map (λ (k : ulift ℕ), ι k) (QprimeFP_int.Tinv BD.data κ₂ κ M)))
  (of_hom (sigma_map (λ (k : ulift ℕ), ι k) (QprimeFP_int.ι BD.data κ₂ κ M)))
  (of_hom (QprimeFP.shift_sub_id ι hι (QprimeFP_int r' BD.data κ₂ M)))
  (of_hom (QprimeFP.shift_sub_id ι hι (QprimeFP_int r' BD.data κ M)))
  (auux $ commsq_shift_sub_id_Tinv _ _ _ _ _ _)
  (auux $ commsq_shift_sub_id_ι _ _ _ _ _ _)
  ((single _ 0).map (Condensed.of_top_ab_map (normed_group_hom.to_add_monoid_hom (normed_with_aut.T.inv : V ⟶ V)) (normed_group_hom.continuous _)))
  i).bicartesian :=
begin
  have h1 := _, have h2 := _, have h3 := _,
  refine commsq.bicartesian.of_iso
    (pi_Ext_iso_Ext_sigma _ _ _ _ _ _) (pi_Ext_iso_Ext_sigma _ _ _ _ _ _)
    (pi_Ext_iso_Ext_sigma _ _ _ _ _ _) (pi_Ext_iso_Ext_sigma _ _ _ _ _ _)
    h1 h2 h2 h3 H1,
  apply Tinv2_iso_of_bicartesian_aux_1,
  { sorry },
  apply Tinv2_iso_of_bicartesian_aux_1,
end

lemma Tinv2_iso_of_bicartesian [normed_with_aut r V]
  [∀ c n, fact (κ₂ c n ≤ κ c n)] [∀ c n, fact (κ₂ c n ≤ r' * κ c n)]
  (hκ : Lbar.sufficiently_increasing κ ι hι)
  (hκ₂ : Lbar.sufficiently_increasing κ₂ ι hι)
  (i : ℤ)
  (H1 : (shift_sub_id.commsq (ExtQprime.Tinv2 r r' BD.data κ κ₂ M V i) ι hι).bicartesian)
  (H2 : (shift_sub_id.commsq (ExtQprime.Tinv2 r r' BD.data κ κ₂ M V (i+1)) ι hι).bicartesian) :
  is_iso (((Ext (i+1)).map ((BD.eval freeCond'.{u}).map M.Tinv_cond).op).app
    ((single (Condensed Ab) 0).obj V.to_Cond) -
    ((Ext (i+1)).obj ((BD.eval freeCond').op.obj (op (M.to_Condensed)))).map
      ((single (Condensed Ab) 0).map
        (Condensed.of_top_ab_map
          (normed_group_hom.to_add_monoid_hom normed_with_aut.T.inv) (normed_group_hom.continuous _)))) :=
begin
  let Vc := (single (Condensed Ab) 0).obj V.to_Cond,
  have SES₁ := QprimeFP.short_exact BD κ₂ M ι hι hκ₂,
  have SES₂ := QprimeFP.short_exact BD κ M ι hι hκ,
  have := Ext_iso_of_bicartesian_of_bicartesian SES₁ SES₂
    (sigma_map _ (QprimeFP_int.Tinv BD.data _ _ M))
    (sigma_map _ (QprimeFP_int.Tinv BD.data _ _ M))
    (category_theory.functor.map _ M.Tinv_cond)
    (sigma_map _ (QprimeFP_int.ι BD.data _ _ M))
    (sigma_map _ (QprimeFP_int.ι BD.data _ _ M))
    (commsq_shift_sub_id_Tinv BD.data _ _ M ι hι)
    (commsq_sigma_proj_Tinv BD _ _ M ι)
    (commsq_shift_sub_id_ι BD.data _ _ M ι hι)
    (commsq_sigma_proj_ι BD _ _ M ι)
    Vc ((single _ _).map $ Condensed.of_top_ab_map
      (normed_group_hom.to_add_monoid_hom normed_with_aut.T.inv) (normed_group_hom.continuous _))
    _
    (Tinv2_iso_of_bicartesian_aux _ _ _ _ _ _ _ _ _ H1)
    (Tinv2_iso_of_bicartesian_aux _ _ _ _ _ _ _ _ _ H2),
  delta Ext_Tinv2 at this,
  simpa only [op_id, category_theory.functor.map_id, category.id_comp, nat_trans.id_app],
end

lemma Tinv2_iso_of_bicartesian' [normed_with_aut r V]
  [∀ c n, fact (κ₂ c n ≤ κ c n)] [∀ c n, fact (κ₂ c n ≤ r' * κ c n)]
  (H : ∀ i, ∃ (ι) (hι),
    Lbar.sufficiently_increasing κ ι hι ∧
    Lbar.sufficiently_increasing κ₂ ι hι ∧
    (shift_sub_id.commsq (ExtQprime.Tinv2 r r' BD.data κ κ₂ M V i) ι hι).bicartesian ∧
    (shift_sub_id.commsq (ExtQprime.Tinv2 r r' BD.data κ κ₂ M V (i+1)) ι hι).bicartesian)
  (i : ℤ) :
  is_iso (((Ext i).map ((BD.eval freeCond'.{u}).map M.Tinv_cond).op).app
    ((single (Condensed Ab) 0).obj V.to_Cond) -
    ((Ext i).obj ((BD.eval freeCond').op.obj (op (M.to_Condensed)))).map
      ((single (Condensed Ab) 0).map
        (Condensed.of_top_ab_map
          (normed_group_hom.to_add_monoid_hom normed_with_aut.T.inv) (normed_group_hom.continuous _)))) :=
begin
  obtain ⟨i, rfl⟩ : ∃ k, k+1 = i := ⟨i-1, sub_add_cancel _ _⟩,
  obtain ⟨ι, hι, hκ, hκ₂, H1, H2⟩ := H i,
  apply Tinv2_iso_of_bicartesian _ _ _ _ _ _ ι hι hκ hκ₂ i H1 H2,
end

end preps

namespace Lbar

open ProFiltPseuNormGrpWithTinv₁ ProFiltPseuNormGrp₁ CompHausFiltPseuNormGrp₁
open bounded_homotopy_category

variables (r r')

def Tinv_sub (S : Profinite.{u}) (V : SemiNormedGroup.{u}) [normed_with_aut r V] (i : ℤ) :
  ((Ext' i).obj (op $ (Lbar.condensed.{u} r').obj S)).obj V.to_Cond ⟶
  ((Ext' i).obj (op $ (Lbar.condensed.{u} r').obj S)).obj V.to_Cond :=
((Ext' i).map ((condensify_Tinv _).app S).op).app _ -
((Ext' i).obj _).map (Condensed.of_top_ab_map (normed_with_aut.T.inv).to_add_monoid_hom
  (normed_group_hom.continuous _))

-- move me
attribute [simps] Condensed.of_top_ab_map

variables (S : Profinite.{0}) (V : SemiNormedGroup.{0})
variables [complete_space V] [separated_space V]
variables (r')

def condensify_iso_extend :
  condensify (Fintype_Lbar.{0 0} r' ⋙ PFPNGT₁_to_CHFPNG₁ₑₗ r') ≅
  (Profinite.extend (Fintype_Lbar.{0 0} r')) ⋙
    (PFPNGT₁_to_CHFPNG₁ₑₗ r' ⋙ CHFPNG₁_to_CHFPNGₑₗ.{0} ⋙
  CompHausFiltPseuNormGrp.to_Condensed.{0}) :=
(((whiskering_left _ _ _).map_iso $
  Profinite.extend_commutes (Fintype_Lbar.{0 0} r') (PFPNGT₁_to_CHFPNG₁ₑₗ r')).app
    (CHFPNG₁_to_CHFPNGₑₗ.{0} ⋙ CompHausFiltPseuNormGrp.to_Condensed.{0})).symm

def condensify_iso_extend' :
  (condensify (Fintype_Lbar.{0 0} r' ⋙ PFPNGT₁_to_CHFPNG₁ₑₗ r')).obj S ≅
  ((Profinite.extend (Fintype_Lbar.{0 0} r')).obj S).to_Condensed :=
(condensify_iso_extend r').app S

section move_me

--universes u'

open Profinite

variables {C : Type u} [category.{v} C] (F : Fintype.{v} ⥤ C)
variables {D : Type u'} [category.{v} D]
variable [∀ X : Profinite, has_limit (X.fintype_diagram ⋙ F)]

@[reassoc]
lemma extend_commutes_comp_extend_extends' (G : C ⥤ D)
  [∀ X : Profinite.{v}, preserves_limits_of_shape (discrete_quotient X) G]
  [∀ X : Profinite.{v}, has_limit (X.fintype_diagram ⋙ F ⋙ G)] :
  whisker_left Fintype.to_Profinite (extend_commutes F G).hom =
  (functor.associator _ _ _).inv ≫ (whisker_right (extend_extends _).hom G) ≫
    (extend_extends _).inv :=
by rw [← category.assoc, iso.eq_comp_inv, extend_commutes_comp_extend_extends]

@[reassoc]
lemma extend_commutes_comp_extend_extends'' (G : C ⥤ D)
  [∀ X : Profinite.{v}, preserves_limits_of_shape (discrete_quotient X) G]
  [∀ X : Profinite.{v}, has_limit (X.fintype_diagram ⋙ F ⋙ G)] :
  whisker_left Fintype.to_Profinite (extend_commutes F G).inv =
  (extend_extends _).hom ≫ (whisker_right (extend_extends _).inv G) ≫
    (functor.associator _ _ _).hom :=
begin
  rw [← iso.inv_comp_eq, ← iso_whisker_left_inv, iso.comp_inv_eq, iso_whisker_left_hom,
    extend_commutes_comp_extend_extends', category.assoc, iso.hom_inv_id_assoc,
    ← iso_whisker_right_hom, ← iso_whisker_right_inv, iso.inv_hom_id_assoc],
end

end move_me

lemma condensify_Tinv_iso :
  condensify_Tinv (Fintype_Lbar.{0 0} r') ≫ (condensify_iso_extend r').hom =
  (condensify_iso_extend r').hom ≫ (@whisker_right _ _ _ _ _ _ _ _ (Tinv_nat_trans _) _) :=
begin
  delta Tinv_cond condensify_Tinv condensify_nonstrict condensify_iso_extend' condensify_iso_extend,
  ext S : 2,
  rw [iso.symm_hom, iso.app_inv, functor.map_iso_inv, nat_trans.comp_app, nat_trans.comp_app,
    whiskering_left_map_app_app, ← iso.app_inv, ← functor.map_iso_inv, iso.comp_inv_eq,
    functor.map_iso_inv, functor.map_iso_hom, functor.comp_map, functor.comp_map,
    whisker_right_app, whisker_right_app, ← functor.map_comp, ← functor.map_comp],
  congr' 1,
  rw [iso.app_inv, iso.app_hom, ← whisker_right_app, ← whisker_right_app,
    ← nat_trans.comp_app, ← nat_trans.comp_app],
  congr' 1,
  refine nonstrict_extend_ext _ _ (r'⁻¹) (1 * (r'⁻¹ * 1)) _ _ _,
  { intro X, apply nonstrict_extend_bound_by },
  { intro X,
    apply comphaus_filtered_pseudo_normed_group_hom.bound_by.comp,
    apply comphaus_filtered_pseudo_normed_group_hom.bound_by.comp,
    { apply strict_comphaus_filtered_pseudo_normed_group_hom.to_chfpsng_hom.bound_by_one },
    { apply Tinv_bound_by },
    { apply strict_comphaus_filtered_pseudo_normed_group_hom.to_chfpsng_hom.bound_by_one }, },
  { rw [whisker_left_comp, whisker_left_comp, ← whisker_right_left, ← whisker_right_left,
      extend_commutes_comp_extend_extends', extend_commutes_comp_extend_extends''],
    rw nonstrict_extend_whisker_left,

    ext X : 2,
    simp only [whisker_left_app, whisker_right_app, nat_trans.comp_app,
      functor.associator_hom_app, functor.associator_inv_app,
      category.id_comp, category.comp_id, category.assoc, functor.map_comp],
    slice_rhs 2 3 {},
    congr' 2,

    simp only [← iso.app_hom, ← iso.app_inv, ← functor.map_iso_hom, ← functor.map_iso_inv,
      category.assoc, iso.eq_inv_comp],

    ext x : 1,
    exact (comphaus_filtered_pseudo_normed_group_with_Tinv_hom.map_Tinv
      ((Profinite.extend_extends (Fintype_Lbar.{0 0} r')).app X).hom x).symm }
end

lemma condensify_Tinv_iso' :
  (condensify_Tinv (Fintype_Lbar.{0 0} r')).app S ≫ (condensify_iso_extend' r' S).hom =
  (condensify_iso_extend' r' S).hom ≫ ((Profinite.extend (Fintype_Lbar.{0 0} r')).obj S).Tinv_cond :=
begin
  have := condensify_Tinv_iso r',
  apply_fun (λ η, η.app S) at this,
  exact this,
end

def useful_commsq (i : ℤ) (ι : ulift.{1} ℕ → ℝ≥0) (hι : monotone ι) [normed_with_aut r V] :=
  shift_sub_id.commsq
    (ExtQprime.Tinv2 r r' breen_deligne.eg.data
      (λ c n, c * breen_deligne.eg.κ r r' n)
      (λ c n, r' * (c * breen_deligne.eg.κ r r' n))
      ((Lbar.functor.{0 0} r').obj S) V i) ι hι

section
open breen_deligne thm95.universal_constants

variables (i : ℕ)

lemma useful_commsq_bicartesian (ι : ulift.{1} ℕ → ℝ≥0) (hι : monotone ι) [normed_with_aut r V]
  (H1 : ∀ j, c₀ r r' eg (λ n, eg.κ r r' n) (eg.κ' r r') (i+1) ⟨ℤ⟩ ≤ ι j)
  (H2 : ∀ j, k (eg.κ' r r') i ^ 2 * ι j ≤ ι (j + 1))
  (H3 : ∀ j, k (eg.κ' r r') (i+1) ^ 2 * ι j ≤ ι (j + 1)) :
  (useful_commsq r r' S V i ι hι).bicartesian :=
begin
  apply shift_sub_id.bicartesian_iso _ _
    (ExtQprime_iso_aux_system r' _ _ _ V i).symm (ExtQprime_iso_aux_system r' _ _ _ V i).symm ι hι
    (ExtQprime_iso_aux_system_comm' _ _ _ _ _ _ _ _),
  rw [← whisker_right_twice],
  refine shift_sub_id.bicartesian (aux_system.incl'.{0 1} r r' _ _ _ (eg.κ r r')) _
    i ι hι _ _ _,
  { apply_with system_of_complexes.shift_eq_zero {instances := ff},
    swap 3, { apply thm94.explicit r r' _ _ (eg.κ' r r'), },
    any_goals { apply_instance },
    { intro j,
      refine le_trans _ ((c₀_mono _ _ _ _ _ _ (i+1)).out.trans (H1 j)),
      rw nat.add_sub_cancel, },
    { exact H2 } },
  { apply_with system_of_complexes.shift_eq_zero {instances := ff},
    swap 3, { apply thm94.explicit r r' _ _ (eg.κ' r r'), },
    any_goals { apply_instance },
    { exact H1 },
    { exact H3 } },
  { intros c n,
    let κ := eg.κ r r',
    apply aux_system.short_exact r r' _ _ _ (λ c n, r' * (c * κ n)) κ,
    intro c, dsimp, apply_instance, }
end

lemma bicartesian_of_is_zero {𝓒 : Type*} [category 𝓒] [abelian 𝓒]
  {A B C D : 𝓒} (f₁ : A ⟶ B) (g₁ : A ⟶ C) (g₂ : B ⟶ D) (f₂ : C ⟶ D) (h : commsq f₁ g₁ g₂ f₂)
  (hA : is_zero A) (hB : is_zero B) (hC : is_zero C) (hD : is_zero D) :
  h.bicartesian :=
begin
  delta commsq.bicartesian,
  apply_with short_exact.mk {instances:=ff},
  { refine ⟨λ X f g h, _⟩, apply hA.eq_of_tgt },
  { refine ⟨λ X f g h, _⟩, apply hD.eq_of_src },
  { apply exact_of_is_zero ((is_zero_biprod _ _ hB hC).of_iso (h.sum.iso (sum_str.biprod _ _))), }
end

lemma is_zero_pi {𝓒 : Type*} [category 𝓒] [abelian 𝓒] {ι : Type*} (f : ι → 𝓒) [has_product f]
  (hf : ∀ i, is_zero (f i)) :
  is_zero (∏ f) :=
begin
  rw is_zero_iff_id_eq_zero,
  ext,
  apply (hf j).eq_of_tgt,
end

lemma useful_commsq_bicartesian_neg  (ι : ulift.{1} ℕ → ℝ≥0) (hι : monotone ι) [normed_with_aut r V]
  (i : ℤ) (hi : i < 0) :
  (useful_commsq r r' S V i ι hι).bicartesian :=
begin
  have : 1 + i ≤ 0, { linarith only [hi] },
  apply bicartesian_of_is_zero;
  apply is_zero_pi; intro x;
  apply Ext_single_right_is_zero _ _ 1 _ _ (chain_complex.bounded_by_one _) this
end

lemma is_iso_sq {𝓒 : Type*} [category 𝓒] {X Y : 𝓒} (f₁ : X ⟶ X) (f₂ : Y ⟶ Y)
  (e : X ≅ Y) (h : f₁ ≫ e.hom = e.hom ≫ f₂) (h₁ : is_iso f₁) :
  is_iso f₂ :=
by { rw [← iso.inv_comp_eq] at h, rw ← h, apply_instance }

open category_theory.preadditive

lemma is_iso_sq' {𝓒 : Type*} [category 𝓒] [abelian 𝓒] [enough_projectives 𝓒]
  {X Y Z : bounded_homotopy_category 𝓒} (f₁ : X ⟶ X) (f₂ : Y ⟶ Y) (f₃ : Z ⟶ Z)
  (e : Y ≅ X) (h : e.hom ≫ f₁ = f₂ ≫ e.hom) (i : ℤ)
  (h₁ : is_iso (((Ext i).map f₁.op).app Z - ((Ext i).obj _).map f₃)) :
  is_iso (((Ext i).map f₂.op).app Z - ((Ext i).obj _).map f₃) :=
begin
  refine is_iso_sq _ _ ((functor.map_iso _ e.op).app _) _ h₁,
  rw [iso.app_hom, functor.map_iso_hom, sub_comp, comp_sub, nat_trans.naturality,
      ← nat_trans.comp_app, ← nat_trans.comp_app, ← functor.map_comp, ← functor.map_comp,
      iso.op_hom, ← op_comp, ← op_comp, h],
end

/-- Thm 9.4bis of [Analytic]. More precisely: the first observation in the proof 9.4 => 9.1. -/
theorem is_iso_Tinv_sub [normed_with_aut r V] : ∀ i, is_iso (Tinv_sub r r' S V i) :=
begin
  erw (Condensed.bd_lemma _ _ _ _),
  swap, { apply Lbar.obj.no_zero_smul_divisors },
  intro i,
  refine is_iso_sq' _ _ _ (functor.map_iso _ $ condensify_iso_extend' _ _) _ _ _,
  { refine category_theory.functor.map _ _, refine Tinv_cond _ },
  { rw [functor.map_iso_hom, ← functor.map_comp, ← functor.map_comp, condensify_Tinv_iso'], },
  revert i,
  refine Tinv2_iso_of_bicartesian' r breen_deligne.eg
      (λ c n, c * breen_deligne.eg.κ r r' n)
      (λ c n, r' * (c * breen_deligne.eg.κ r r' n))
    ((Lbar.functor.{0 0} r').obj S) V _,
  rintro (i|(_|i)),
  { refine ⟨ι r r' i, hι r r' i, _, _, _, _⟩,
    { intros s m,
      apply Lbar.sufficiently_increasing_eg },
    { intros s m,
      apply Lbar.sufficiently_increasing_eg' },
    all_goals { apply useful_commsq_bicartesian },
    { rintro ⟨j⟩, apply Hι1 },
    { rintro ⟨j⟩, apply Hι2a },
    { rintro ⟨j⟩, apply Hι2b },
    { rintro ⟨j⟩, apply Hι1' },
    { rintro ⟨j⟩, apply Hι2b },
    { rintro ⟨j⟩, apply Hι2c } },
  { refine ⟨ι r r' 0, hι r r' 0, _, _, _, _⟩,
    { intros s m, apply Lbar.sufficiently_increasing_eg, },
    { intros s m, apply Lbar.sufficiently_increasing_eg', },
    { apply useful_commsq_bicartesian_neg, dec_trivial },
    { apply useful_commsq_bicartesian,
    { rintro ⟨j⟩, apply Hι1 },
    { rintro ⟨j⟩, apply Hι2a },
    { rintro ⟨j⟩, apply Hι2b }, }, },
  { refine ⟨ι r r' 0, hι r r' 0, _, _, _, _⟩,
    { intros s m, apply Lbar.sufficiently_increasing_eg, },
    { intros s m, apply Lbar.sufficiently_increasing_eg', },
    { apply useful_commsq_bicartesian_neg, dec_trivial },
    { apply useful_commsq_bicartesian_neg,
      rw [int.neg_succ_of_nat_eq'],
      simp only [int.coe_nat_succ, neg_add_rev, sub_add_cancel, add_neg_lt_iff_le_add', add_zero],
      dec_trivial }, },
end

/-- Thm 9.4bis of [Analytic]. More precisely: the first observation in the proof 9.4 => 9.1. -/
theorem is_iso_Tinv2 [normed_with_aut r V]
  (hV : ∀ (v : V), (normed_with_aut.T.inv v) = 2 • v) :
  ∀ i, is_iso (((Ext' i).map ((condensify_Tinv2 (Fintype_Lbar.{0 0} r')).app S).op).app
    (Condensed.of_top_ab ↥V)) :=
begin
  intro i,
  rw [condensify_Tinv2_eq, ← functor.flip_obj_map, nat_trans.app_sub, category_theory.op_sub,
    nat_trans.app_nsmul,  category_theory.op_nsmul, two_nsmul, nat_trans.id_app, op_id,
    functor.map_sub, functor.map_add, category_theory.functor.map_id],
  convert is_iso_Tinv_sub r r' S V i using 2,
  suffices : Condensed.of_top_ab_map (normed_group_hom.to_add_monoid_hom normed_with_aut.T.inv) _ =
    2 • 𝟙 _,
  { rw [this, two_nsmul, functor.map_add, category_theory.functor.map_id], refl, },
  ext T f t,
  dsimp only [Condensed.of_top_ab_map_val, whisker_right_app, Ab.ulift_map_apply_down,
    add_monoid_hom.mk'_apply, continuous_map.coe_mk, function.comp_app],
  erw [hV, two_nsmul, two_nsmul],
  refl,
end

end

end Lbar
