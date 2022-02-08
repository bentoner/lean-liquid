import pseudo_normed_group.category.CompHausFiltPseuNormGrpWithTinv
/-!

# The category of profinitely filtered pseudo-normed groups (and friends).

The category of profinite pseudo-normed groups, and the category of
profinitely filtered pseudo-normed groups equipped with an action of T⁻¹.

-/
universe variables u

open category_theory
open_locale nnreal

local attribute [instance] type_pow

noncomputable theory

/-- The category of profinitely filtered pseudo-normed groups with action of `T⁻¹`. -/
def ProFiltPseuNormGrpWithTinv (r : ℝ≥0) : Type (u+1) :=
bundled (@profinitely_filtered_pseudo_normed_group_with_Tinv r)

namespace ProFiltPseuNormGrpWithTinv

variables (r' : ℝ≥0)

local attribute [instance] CompHausFiltPseuNormGrpWithTinv.bundled_hom

def bundled_hom : bundled_hom.parent_projection
  (@profinitely_filtered_pseudo_normed_group_with_Tinv.to_comphaus_filtered_pseudo_normed_group_with_Tinv r') := ⟨⟩

local attribute [instance] bundled_hom

/-
instance bundled_hom : bundled_hom (@comphaus_filtered_pseudo_normed_group_with_Tinv_hom r') :=
⟨@comphaus_filtered_pseudo_normed_group_with_Tinv_hom.to_fun r',
 @comphaus_filtered_pseudo_normed_group_with_Tinv_hom.id r',
 @comphaus_filtered_pseudo_normed_group_with_Tinv_hom.comp r',
 @comphaus_filtered_pseudo_normed_group_with_Tinv_hom.coe_inj r'⟩
-/

attribute [derive [λ α, has_coe_to_sort α (Sort*), large_category, concrete_category]]
  ProFiltPseuNormGrpWithTinv

/-- Construct a bundled `ProFiltPseuNormGrpWithTinv` from the underlying type and typeclass. -/
def of (r' : ℝ≥0) (M : Type u) [profinitely_filtered_pseudo_normed_group_with_Tinv r' M] :
  ProFiltPseuNormGrpWithTinv r' :=
bundled.of M

instance : has_zero (ProFiltPseuNormGrpWithTinv r') :=
⟨{ α := punit, str := punit.profinitely_filtered_pseudo_normed_group_with_Tinv r' }⟩

instance : inhabited (ProFiltPseuNormGrpWithTinv r') := ⟨0⟩

instance (M : ProFiltPseuNormGrpWithTinv r') :
  profinitely_filtered_pseudo_normed_group_with_Tinv r' M := M.str

@[simp] lemma coe_of (V : Type u) [profinitely_filtered_pseudo_normed_group_with_Tinv r' V] :
  (ProFiltPseuNormGrpWithTinv.of r' V : Type u) = V := rfl

@[simp] lemma of_coe (M : ProFiltPseuNormGrpWithTinv r') : of r' M = M :=
by { cases M, refl }

@[simp] lemma coe_id (V : ProFiltPseuNormGrpWithTinv r') : ⇑(𝟙 V) = id := rfl

@[simp] lemma coe_comp {A B C : ProFiltPseuNormGrpWithTinv r'} (f : A ⟶ B) (g : B ⟶ C) :
  ⇑(f ≫ g) = g ∘ f := rfl

@[simp] lemma coe_comp_apply {A B C : ProFiltPseuNormGrpWithTinv r'} (f : A ⟶ B) (g : B ⟶ C) (x : A) :
  (f ≫ g) x = g (f x) := rfl
open pseudo_normed_group

section

variables (M : Type*) [profinitely_filtered_pseudo_normed_group_with_Tinv r' M] (c : ℝ≥0)
include r'

instance : t2_space (Top.of (filtration M c)) := by { dsimp, apply_instance }
instance : totally_disconnected_space (Top.of (filtration M c)) := by { dsimp, apply_instance }
instance : compact_space (Top.of (filtration M c)) := by { dsimp, apply_instance }

end

-- @[simps] def Filtration (c : ℝ≥0) : ProFiltPseuNormGrp ⥤ Profinite :=
-- { obj := λ M, ⟨Top.of (filtration M c)⟩,
--   map := λ M₁ M₂ f, ⟨f.level c, f.level_continuous c⟩,
--   map_id' := by { intros, ext, refl },
--   map_comp' := by { intros, ext, refl } }


open pseudo_normed_group comphaus_filtered_pseudo_normed_group_with_Tinv_hom

open profinitely_filtered_pseudo_normed_group_with_Tinv (Tinv)

variables {r'}
variables {M M₁ M₂ : ProFiltPseuNormGrpWithTinv.{u} r'}
variables {f : M₁ ⟶ M₂}

/-- The isomorphism induced by a bijective `comphaus_filtered_pseudo_normed_group_with_Tinv_hom`
whose inverse is strict. -/
def iso_of_equiv_of_strict (e : M₁ ≃+ M₂) (he : ∀ x, f x = e x)
  (strict : ∀ ⦃c x⦄, x ∈ filtration M₂ c → e.symm x ∈ filtration M₁ c) :
  M₁ ≅ M₂ :=
{ hom := f,
  inv := inv_of_equiv_of_strict e he strict,
  hom_inv_id' := by { ext x, simp [inv_of_equiv_of_strict, he] },
  inv_hom_id' := by { ext x, simp [inv_of_equiv_of_strict, he] } }

@[simp]
lemma iso_of_equiv_of_strict.apply (e : M₁ ≃+ M₂) (he : ∀ x, f x = e x)
  (strict : ∀ ⦃c x⦄, x ∈ filtration M₂ c → e.symm x ∈ filtration M₁ c) (x : M₁) :
  (iso_of_equiv_of_strict e he strict).hom x = f x := rfl

@[simp]
lemma iso_of_equiv_of_strict_symm.apply (e : M₁ ≃+ M₂) (he : ∀ x, f x = e x)
  (strict : ∀ ⦃c x⦄, x ∈ filtration M₂ c → e.symm x ∈ filtration M₁ c) (x : M₂) :
  (iso_of_equiv_of_strict e he strict).symm.hom x = e.symm x := rfl

def iso_of_equiv_of_strict'
  (e : M₁ ≃+ M₂)
  (strict' : ∀ c x, x ∈ filtration M₁ c ↔ e x ∈ filtration M₂ c)
  (continuous' : ∀ c, continuous (pseudo_normed_group.level e (λ c x, (strict' c x).1) c))
  (map_Tinv' : ∀ x, e (Tinv x) = Tinv (e x)) :
  M₁ ≅ M₂ :=
@iso_of_equiv_of_strict r' M₁ M₂
 {to_fun := e,
  strict' := λ c x, (strict' c x).1,
  continuous' := continuous',
  map_Tinv' := map_Tinv',
  ..e.to_add_monoid_hom } e (λ _, rfl)
  (by { intros c x hx, rwa [strict', e.apply_symm_apply] })

@[simp]
lemma iso_of_equiv_of_strict'_hom_apply
  (e : M₁ ≃+ M₂)
  (strict' : ∀ c x, x ∈ filtration M₁ c ↔ e x ∈ filtration M₂ c)
  (continuous' : ∀ c, continuous (pseudo_normed_group.level e (λ c x, (strict' c x).1) c))
  (map_Tinv' : ∀ x, e (Tinv x) = Tinv (e x))
  (x : M₁) :
  (iso_of_equiv_of_strict' e strict' continuous' map_Tinv').hom x = e x := rfl

@[simp]
lemma iso_of_equiv_of_strict'_inv_apply
  (e : M₁ ≃+ M₂)
  (strict' : ∀ c x, x ∈ filtration M₁ c ↔ e x ∈ filtration M₂ c)
  (continuous' : ∀ c, continuous (pseudo_normed_group.level e (λ c x, (strict' c x).1) c))
  (map_Tinv' : ∀ x, e (Tinv x) = Tinv (e x))
  (x : M₂) :
  (iso_of_equiv_of_strict' e strict' continuous' map_Tinv').inv x = e.symm x := rfl

variables (r')

@[simps]
def Pow (n : ℕ) : ProFiltPseuNormGrpWithTinv.{u} r' ⥤ ProFiltPseuNormGrpWithTinv.{u} r' :=
{ obj := λ M, of r' $ M ^ n,
  map := λ M₁ M₂ f, profinitely_filtered_pseudo_normed_group_with_Tinv.pi_map r' _ _ (λ i, f),
  map_id' := λ M, by { ext, refl },
  map_comp' := by { intros, ext, refl } }

@[simps]
def Pow_Pow_X_equiv (N n : ℕ) :
  M ^ (N * n) ≃+ (M ^ N) ^ n :=
{ to_fun := ((equiv.curry _ _ _).symm.trans (((equiv.prod_comm _ _).trans fin_prod_fin_equiv).arrow_congr (equiv.refl _))).symm,
  map_add' := λ x y, by { ext, refl },
  .. ((equiv.curry _ _ _).symm.trans (((equiv.prod_comm _ _).trans fin_prod_fin_equiv).arrow_congr (equiv.refl _))).symm }

open profinitely_filtered_pseudo_normed_group
open comphaus_filtered_pseudo_normed_group

@[simps]
def Pow_Pow_X (N n : ℕ) (M : ProFiltPseuNormGrpWithTinv.{u} r') :
  (Pow r' N ⋙ Pow r' n).obj M ≅ (Pow r' (N * n)).obj M :=
iso.symm $
iso_of_equiv_of_strict'
  (Pow_Pow_X_equiv r' N n)
  begin
    intros c x,
    dsimp,
    split; intro h,
    { intros i j, exact h (fin_prod_fin_equiv (j, i)) },
    { intro ij,
      have := h (fin_prod_fin_equiv.symm ij).2 (fin_prod_fin_equiv.symm ij).1,
      dsimp [-fin_prod_fin_equiv_symm_apply] at this,
      simpa only [prod.mk.eta, equiv.apply_symm_apply] using this, },
  end
  begin
    intro c, dsimp,
    rw [← (filtration_pi_homeo (λ _, M ^ N) c).comp_continuous_iff,
        ← (filtration_pi_homeo (λ _, M) c).symm.comp_continuous_iff'],
    apply continuous_pi,
    intro i,
    rw [← (filtration_pi_homeo (λ _, M) c).comp_continuous_iff],
    apply continuous_pi,
    intro j,
    have := @continuous_apply _ (λ _, filtration M c) _ (fin_prod_fin_equiv (j, i)),
    dsimp [function.comp] at this ⊢,
    simpa only [subtype.coe_eta],
  end
  (by { intros, ext, refl })

@[simps hom inv]
def Pow_mul (N n : ℕ) : Pow r' (N * n) ≅ Pow r' N ⋙ Pow r' n :=
nat_iso.of_components (λ M, (Pow_Pow_X r' N n M).symm)
begin
  intros X Y f,
  ext x i j,
  refl,
end

end ProFiltPseuNormGrpWithTinv
