import Lbar.ext_preamble

noncomputable theory

universes u

open opposite category_theory category_theory.limits
open_locale nnreal zero_object

variables (r r' : ℝ≥0)
variables [fact (0 < r)] [fact (0 < r')] [fact (r < r')] [fact (r < 1)] [fact (r' < 1)]

open bounded_homotopy_category

variables (BD : breen_deligne.data)
variables (κ κ₂ : ℝ≥0 → ℕ → ℝ≥0)
variables [∀ (c : ℝ≥0), BD.suitable (κ c)] [∀ n, fact (monotone (function.swap κ n))]
variables [∀ (c : ℝ≥0), BD.suitable (κ₂ c)] [∀ n, fact (monotone (function.swap κ₂ n))]
variables (M : ProFiltPseuNormGrpWithTinv₁.{u} r')
variables (V : SemiNormedGroup.{u}) [complete_space V] [separated_space V]

def ExtQprime_iso_aux_system_obj_aux' (X : Profinite.{u}) :
  Ab.ulift.{u+1}.obj
    ((forget₂ SemiNormedGroup Ab).obj
      (SemiNormedGroup.Completion.obj ((SemiNormedGroup.LocallyConstant.obj V).obj (op X)))) ≅
  (forget₂ SemiNormedGroup.{u+1} Ab.{u+1}).obj
    (SemiNormedGroup.Completion.obj
      ((SemiNormedGroup.LocallyConstant.obj (SemiNormedGroup.ulift.{u+1}.obj V)).obj (op X))) :=
begin
  refine add_equiv.to_AddCommGroup_iso _,
  refine add_equiv.ulift.trans _,
  refine add_equiv.mk _ _ _ _ _,
  { refine normed_group_hom.completion _,
    refine locally_constant.map_hom _,
    refine { bound' := ⟨1, λ v, _⟩, .. add_equiv.ulift.symm },
    rw one_mul, exact le_rfl },
  { refine uniform_space.completion.map _,
    refine locally_constant.map_hom _,
    refine { bound' := ⟨1, λ v, _⟩, .. add_equiv.ulift },
    rw one_mul, exact le_rfl },
  { erw [function.left_inverse_iff_comp, uniform_space.completion.map_comp],
    { have : ulift.down.{u+1} ∘ ulift.up.{u+1} = (id : V → V) := rfl,
      erw [locally_constant.map_comp, this, locally_constant.map_id, uniform_space.completion.map_id] },
    { apply normed_group_hom.uniform_continuous, },
    { apply normed_group_hom.uniform_continuous, } },
  { erw [function.right_inverse_iff_comp, uniform_space.completion.map_comp],
    { have : ulift.up.{u+1 u} ∘ ulift.down.{u+1} = @id (ulift V) := by { ext v, refl },
      erw [locally_constant.map_comp, this, locally_constant.map_id, uniform_space.completion.map_id] },
    { apply normed_group_hom.uniform_continuous, },
    { apply normed_group_hom.uniform_continuous, } },
  { intros x y, apply normed_group_hom.map_add, }
end

-- jmc: is this helpful??
-- @[reassoc]
-- lemma ExtQprime_iso_aux_system_obj_aux'_natural (X Y : Profinite.{u}) (f : X ⟶ Y) :
--   (ExtQprime_iso_aux_system_obj_aux' V Y).hom ≫
--     (forget₂ _ _).map (SemiNormedGroup.Completion.map ((SemiNormedGroup.LocallyConstant.obj _).map f.op)) =
--     Ab.ulift.map ((forget₂ _ _).map (SemiNormedGroup.Completion.map ((SemiNormedGroup.LocallyConstant.obj _).map f.op))) ≫
--  (ExtQprime_iso_aux_system_obj_aux' V X).hom :=
-- begin
--   ext1 φ, simp only [comp_apply],
--   dsimp only [ExtQprime_iso_aux_system_obj_aux', add_equiv.to_AddCommGroup_iso,
--     add_equiv.trans_apply, add_equiv.coe_to_add_monoid_hom, add_equiv.coe_mk,
--     Ab.ulift_map_apply],
--   admit
-- end
.