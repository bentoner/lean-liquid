import for_mathlib.normed_group_hom_equalizer
import pseudo_normed_group.CLC

open_locale classical nnreal
noncomputable theory
local attribute [instance] type_pow

namespace category_theory

theorem comm_sq₂ {C} [category C] {A₁ A₂ A₃ B₁ B₂ B₃ : C}
  {f₁ : A₁ ⟶ B₁} {f₂ : A₂ ⟶ B₂} {f₃ : A₃ ⟶ B₃}
  {a : A₁ ⟶ A₂} {a' : A₂ ⟶ A₃} {b : B₁ ⟶ B₂} {b' : B₂ ⟶ B₃}
  (h₁ : a ≫ f₂ = f₁ ≫ b) (h₂ : a' ≫ f₃ = f₂ ≫ b') : (a ≫ a') ≫ f₃ = f₁ ≫ b ≫ b' :=
by rw [category.assoc, h₂, ← category.assoc, h₁, ← category.assoc]

end category_theory

open NormedGroup opposite Profinite pseudo_normed_group category_theory breen_deligne
open profinitely_filtered_pseudo_normed_group category_theory.limits
open normed_group_hom

namespace NormedGroup
namespace equalizer
def map {V₁ V₂ W₁ W₂ : NormedGroup} {f₁ f₂ g₁ g₂} (φ : V₁ ⟶ V₂) (ψ : W₁ ⟶ W₂)
  (hf : φ ≫ f₂ = f₁ ≫ ψ) (hg : φ ≫ g₂ = g₁ ≫ ψ) :
  of (f₁.equalizer g₁) ⟶ of (f₂.equalizer g₂) :=
normed_group_hom.equalizer.map _ _ hf.symm hg.symm

lemma map_comp_map {V₁ V₂ V₃ W₁ W₂ W₃ : NormedGroup} {f₁ f₂ f₃ g₁ g₂ g₃}
  {φ : V₁ ⟶ V₂} {ψ : W₁ ⟶ W₂} {φ' : V₂ ⟶ V₃} {ψ' : W₂ ⟶ W₃}
  (hf : φ ≫ f₂ = f₁ ≫ ψ) (hg : φ ≫ g₂ = g₁ ≫ ψ)
  (hf' : φ' ≫ f₃ = f₂ ≫ ψ') (hg' : φ' ≫ g₃ = g₂ ≫ ψ') :
  map φ ψ hf hg ≫ map φ' ψ' hf' hg' =
  map (φ ≫ φ') (ψ ≫ ψ') (comm_sq₂ hf hf') (comm_sq₂ hg hg') :=
by { ext, refl }

@[simps obj map]
protected def F {J} [category J] {V W : J ⥤ NormedGroup} (f g : V ⟶ W) : J ⥤ NormedGroup :=
{ obj := λ X, of ((f.app X).equalizer (g.app X)),
  map := λ X Y φ, equalizer.map (V.map φ) (W.map φ) (f.naturality _) (g.naturality _),
  map_id' := λ X, by simp only [category_theory.functor.map_id]; exact equalizer.map_id,
  map_comp' := λ X Y Z φ ψ, begin
    simp only [functor.map_comp],
    exact (map_comp_map _ _ _ _).symm
  end }

def map_nat {J} [category J] {V₁ V₂ W₁ W₂ : J ⥤ NormedGroup}
  {f₁ f₂ g₁ g₂} (φ : V₁ ⟶ V₂) (ψ : W₁ ⟶ W₂)
  (hf : φ ≫ f₂ = f₁ ≫ ψ) (hg : φ ≫ g₂ = g₁ ≫ ψ) :
  equalizer.F f₁ g₁ ⟶ equalizer.F f₂ g₂ :=
{ app := λ X, equalizer.map (φ.app X) (ψ.app X)
    (by rw [← nat_trans.comp_app, ← nat_trans.comp_app, hf])
    (by rw [← nat_trans.comp_app, ← nat_trans.comp_app, hg]),
  naturality' := λ X Y α, by simp only [equalizer.F_map, map_comp_map, nat_trans.naturality] }

lemma map_nat_comp_map_nat {J} [category J] {V₁ V₂ V₃ W₁ W₂ W₃ : J ⥤ NormedGroup}
  {f₁ f₂ f₃ g₁ g₂ g₃} {φ : V₁ ⟶ V₂} {ψ : W₁ ⟶ W₂} {φ' : V₂ ⟶ V₃} {ψ' : W₂ ⟶ W₃}
  (hf : φ ≫ f₂ = f₁ ≫ ψ) (hg : φ ≫ g₂ = g₁ ≫ ψ)
  (hf' : φ' ≫ f₃ = f₂ ≫ ψ') (hg' : φ' ≫ g₃ = g₂ ≫ ψ') :
  map_nat φ ψ hf hg ≫ map_nat φ' ψ' hf' hg' =
  map_nat (φ ≫ φ') (ψ ≫ ψ') (comm_sq₂ hf hf') (comm_sq₂ hg hg') :=
by { ext, refl }

end equalizer
end NormedGroup

universe variable u
variables (r : ℝ≥0) (V : NormedGroup) [normed_with_aut r V] [fact (0 < r)]
variables (r' : ℝ≥0) [fact (0 < r')] [fact (r' ≤ 1)]
variables (M M₁ M₂ M₃ : ProFiltPseuNormGrpWithTinv.{u} r')
variables (c c₁ c₂ c₃ c₄ c₅ c₆ : ℝ≥0) (l m n : ℕ)
variables (f : M₁ ⟶ M₂) (g : M₂ ⟶ M₃)

/-- The "functor" that sends `M` and `c` to `V-hat((filtration M c)^n)^{T⁻¹}`,
defined by taking `T⁻¹`-invariants
for two different actions by `T⁻¹`:

* The first comes from the action of `T⁻¹` on `M`.
* The second comes from the action of `T⁻¹` on `V`.

We take the equalizer of those two actions.

See the lines just above Definition 9.3 of [Analytic]. -/
def CLCPTinv (r : ℝ≥0) (V : NormedGroup) (n : ℕ)
  [normed_with_aut r V] [fact (0 < r)] {A B : Profiniteᵒᵖ} (f g : A ⟶ B) :
  NormedGroup :=
NormedGroup.of $ normed_group_hom.equalizer
  ((CLCP V n).map f)
  ((CLCP.T_inv r V n).app A ≫ (CLCP V n).map g)

namespace CLCPTinv

def map {A₁ B₁ A₂ B₂ : Profiniteᵒᵖ} (f₁ g₁ : A₁ ⟶ B₁) (f₂ g₂ : A₂ ⟶ B₂)
  (ϕ : A₁ ⟶ A₂) (ψ : B₁ ⟶ B₂) (h₁ : ϕ ≫ f₂ = f₁ ≫ ψ) (h₂ : ϕ ≫ g₂ = g₁ ≫ ψ) :
  CLCPTinv r V n f₁ g₁ ⟶ CLCPTinv r V n f₂ g₂ :=
NormedGroup.equalizer.map ((CLCP V n).map ϕ) ((CLCP V n).map ψ)
  (by rw [← functor.map_comp, ← functor.map_comp, h₁]) $
by rw [← category.assoc, (CLCP.T_inv _ _ _).naturality,
  category.assoc, category.assoc, ← functor.map_comp, ← functor.map_comp, h₂]

lemma map_norm_noninc {A₁ B₁ A₂ B₂ : Profiniteᵒᵖ} (f₁ g₁ : A₁ ⟶ B₁) (f₂ g₂ : A₂ ⟶ B₂)
  (ϕ : A₁ ⟶ A₂) (ψ : B₁ ⟶ B₂) (h₁ h₂) :
  (CLCPTinv.map r V n f₁ g₁ f₂ g₂ ϕ ψ h₁ h₂).norm_noninc :=
equalizer.map_norm_noninc _ _ $ CLCP.map_norm_noninc _ _ _

@[simp] lemma map_id {A B : Profiniteᵒᵖ} (f g : A ⟶ B) :
  map r V n f g f g (𝟙 A) (𝟙 B) rfl rfl = 𝟙 _ :=
begin
  simp only [map, NormedGroup.equalizer.map, category_theory.functor.map_id],
  exact equalizer.map_id,
end

lemma map_comp {A₁ A₂ A₃ B₁ B₂ B₃ : Profiniteᵒᵖ}
  {f₁ g₁ : A₁ ⟶ B₁} {f₂ g₂ : A₂ ⟶ B₂} {f₃ g₃ : A₃ ⟶ B₃}
  (ϕ₁ : A₁ ⟶ A₂) (ϕ₂ : A₂ ⟶ A₃) (ψ₁ : B₁ ⟶ B₂) (ψ₂ : B₂ ⟶ B₃)
  (h1 h2 h3 h4 h5 h6) :
  CLCPTinv.map r V n f₁ g₁ f₃ g₃ (ϕ₁ ≫ ϕ₂) (ψ₁ ≫ ψ₂) h1 h2 =
  CLCPTinv.map r V n f₁ g₁ f₂ g₂ ϕ₁ ψ₁ h3 h4 ≫
  CLCPTinv.map r V n f₂ g₂ f₃ g₃ ϕ₂ ψ₂ h5 h6 :=
begin
  simp only [map, NormedGroup.equalizer.map, category_theory.functor.map_comp],
  exact (equalizer.map_comp_map _ _ _ _).symm,
end

lemma map_comp_map {A₁ A₂ A₃ B₁ B₂ B₃ : Profiniteᵒᵖ}
  {f₁ g₁ : A₁ ⟶ B₁} {f₂ g₂ : A₂ ⟶ B₂} {f₃ g₃ : A₃ ⟶ B₃}
  (ϕ₁ : A₁ ⟶ A₂) (ϕ₂ : A₂ ⟶ A₃) (ψ₁ : B₁ ⟶ B₂) (ψ₂ : B₂ ⟶ B₃)
  (h₁ h₂ h₃ h₄) :
  CLCPTinv.map r V n f₁ g₁ f₂ g₂ ϕ₁ ψ₁ h₁ h₂ ≫
  CLCPTinv.map r V n f₂ g₂ f₃ g₃ ϕ₂ ψ₂ h₃ h₄ =
  CLCPTinv.map r V n f₁ g₁ f₃ g₃ (ϕ₁ ≫ ϕ₂) (ψ₁ ≫ ψ₂) (comm_sq₂ h₁ h₃) (comm_sq₂ h₂ h₄) :=
(map_comp _ _ _ _ _ _ _ _ _ _ _ _ _).symm

@[simps]
protected def F {J} [category J] (r : ℝ≥0) (V : NormedGroup) (n : ℕ)
  [normed_with_aut r V] [fact (0 < r)] {A B : J ⥤ Profiniteᵒᵖ} (f g : A ⟶ B) :
  J ⥤ NormedGroup :=
{ obj := λ X, CLCPTinv r V n (f.app X) (g.app X),
  map := λ X Y φ, map _ _ _ _ _ _ _ (A.map φ) (B.map φ) (f.naturality _) (g.naturality _),
  map_id' := λ X, by simp only [category_theory.functor.map_id]; apply map_id,
  map_comp' := λ X Y Z φ ψ, by simp only [functor.map_comp]; apply map_comp }

theorem F_def {J} [category J] (r : ℝ≥0) (V : NormedGroup) (n : ℕ)
  [normed_with_aut r V] [fact (0 < r)] {A B : J ⥤ Profiniteᵒᵖ} (f g : A ⟶ B) :
  CLCPTinv.F r V n f g = NormedGroup.equalizer.F
    (whisker_right f (CLCP V n))
    (whisker_left A (CLCP.T_inv r V n) ≫ whisker_right g (CLCP V n)) := rfl

@[simp]
def map_nat {J} [category J] {A₁ B₁ A₂ B₂ : J ⥤ Profiniteᵒᵖ} (f₁ g₁ : A₁ ⟶ B₁) (f₂ g₂ : A₂ ⟶ B₂)
  (ϕ : A₁ ⟶ A₂) (ψ : B₁ ⟶ B₂) (h₁ : ϕ ≫ f₂ = f₁ ≫ ψ) (h₂ : ϕ ≫ g₂ = g₁ ≫ ψ) :
  CLCPTinv.F r V n f₁ g₁ ⟶ CLCPTinv.F r V n f₂ g₂ :=
{ app := λ X, map _ _ _ _ _ _ _ (ϕ.app X) (ψ.app X)
    (by rw [← nat_trans.comp_app, h₁, nat_trans.comp_app])
    (by rw [← nat_trans.comp_app, h₂, nat_trans.comp_app]),
  naturality' := λ X Y α, by simp only [CLCPTinv.F_map, map_comp_map, ϕ.naturality, ψ.naturality] }

end CLCPTinv

def aux (r' c c₂ : ℝ≥0) [r1 : fact (r' ≤ 1)] [h : fact (c₂ ≤ r' * c)] : fact (c₂ ≤ c) :=
⟨h.1.trans $ (mul_le_mul' r1.1 le_rfl).trans (by simp)⟩

/-- The "functor" that sends `M` and `c` to `V-hat((filtration M c)^n)^{T⁻¹}`,
defined by taking `T⁻¹`-invariants
for two different actions by `T⁻¹`:

* The first comes from the action of `T⁻¹` on `M`.
* The second comes from the action of `T⁻¹` on `V`.

We take the equalizer of those two actions.

See the lines just above Definition 9.3 of [Analytic]. -/
@[simps obj]
def CLCFPTinv₂ (r : ℝ≥0) (V : NormedGroup)
  (r' : ℝ≥0) [fact (0 < r)] [fact (0 < r')] [r1 : fact (r' ≤ 1)] [normed_with_aut r V]
  (c c₂ : ℝ≥0) [fact (c₂ ≤ r' * c)] (n : ℕ) : (ProFiltPseuNormGrpWithTinv r')ᵒᵖ ⥤ NormedGroup :=
by haveI : fact (c₂ ≤ c) := aux r' c c₂; exact
CLCPTinv.F r V n
  (nat_trans.op (Filtration.Tinv₀ c₂ c))
  (nat_trans.op (Filtration.res r' c₂ c))

theorem CLCFPTinv₂_def (r : ℝ≥0) (V : NormedGroup)
  (r' : ℝ≥0) [fact (0 < r)] [fact (0 < r')] [r1 : fact (r' ≤ 1)] [normed_with_aut r V]
  (c c₂ : ℝ≥0) [fact (c₂ ≤ r' * c)] (n : ℕ) :
  CLCFPTinv₂ r V r' c c₂ n = NormedGroup.equalizer.F
    (CLCFP.Tinv V r' c c₂ n)
    (CLCFP.T_inv r V r' c n ≫ @CLCFP.res V r' c c₂ n (aux r' c c₂)) := rfl

/-- The "functor" that sends `M` and `c` to `V-hat((filtration M c)^n)^{T⁻¹}`,
defined by taking `T⁻¹`-invariants
for two different actions by `T⁻¹`:

* The first comes from the action of `T⁻¹` on `M`.
* The second comes from the action of `T⁻¹` on `V`.

We take the equalizer of those two actions.

See the lines just above Definition 9.3 of [Analytic]. -/
def CLCFPTinv (r : ℝ≥0) (V : NormedGroup) (r' : ℝ≥0)
  (c : ℝ≥0) (n : ℕ) [normed_with_aut r V] [fact (0 < r)] [fact (0 < r')] [fact (r' ≤ 1)] :
  (ProFiltPseuNormGrpWithTinv r')ᵒᵖ ⥤ NormedGroup :=
CLCFPTinv₂ r V r' c (r' * c) n

namespace CLCFPTinv₂

lemma map_norm_noninc [fact (c₂ ≤ r' * c)] [fact (c₂ ≤ c)]
  {M₁ M₂} (f : M₁ ⟶ M₂) : ((CLCFPTinv₂ r V r' c c₂ n).map f).norm_noninc :=
CLCPTinv.map_norm_noninc _ _ _ _ _ _ _ _ _ _ _

def res [fact (c₂ ≤ r' * c₁)] [fact (c₂ ≤ c₁)] [fact (c₄ ≤ r' * c₃)] [fact (c₄ ≤ c₃)]
  [fact (c₃ ≤ c₁)] [fact (c₄ ≤ c₂)] : CLCFPTinv₂ r V r' c₁ c₂ n ⟶ CLCFPTinv₂ r V r' c₃ c₄ n :=
CLCPTinv.map_nat r V _ _ _ _ _
  (nat_trans.op (Filtration.res _ c₃ c₁))
  (nat_trans.op (Filtration.res _ c₄ c₂)) rfl rfl

@[simp] lemma res_refl [fact (c₂ ≤ r' * c₁)] [fact (c₂ ≤ c₁)] : res r V r' c₁ c₂ c₁ c₂ n = 𝟙 _ :=
by { simp only [res, Filtration.res_refl, nat_trans.op_id], ext x : 2, apply CLCPTinv.map_id }

lemma res_comp_res
  [fact (c₂ ≤ r' * c₁)] [fact (c₂ ≤ c₁)]
  [fact (c₄ ≤ r' * c₃)] [fact (c₄ ≤ c₃)]
  [fact (c₆ ≤ r' * c₅)] [fact (c₆ ≤ c₅)]
  [fact (c₃ ≤ c₁)] [fact (c₄ ≤ c₂)]
  [fact (c₅ ≤ c₃)] [fact (c₆ ≤ c₄)]
  [fact (c₅ ≤ c₁)] [fact (c₆ ≤ c₂)] :
  res r V r' c₁ c₂ c₃ c₄ n ≫ res r V r' c₃ c₄ c₅ c₆ n = res r V r' c₁ c₂ c₅ c₆ n :=
begin
  ext x : 2, simp only [res, nat_trans.comp_app],
  exact (CLCPTinv.map_comp _ _ _ _ _ _ _ _ _ _ _ _ _).symm
end

end CLCFPTinv₂

namespace CLCFPTinv

lemma map_norm_noninc {M₁ M₂} (f : M₁ ⟶ M₂) : ((CLCFPTinv r V r' c n).map f).norm_noninc :=
CLCFPTinv₂.map_norm_noninc _ _ _ _ _ _ _

def res [fact (c₂ ≤ c₁)] : CLCFPTinv r V r' c₁ n ⟶ CLCFPTinv r V r' c₂ n :=
CLCFPTinv₂.res r V r' c₁ _ c₂ _ n

@[simp] lemma res_refl : res r V r' c₁ c₁ n = 𝟙 _ :=
CLCFPTinv₂.res_refl _ _ _ _ _ _

lemma res_comp_res [fact (c₃ ≤ c₁)] [fact (c₅ ≤ c₃)] [fact (c₅ ≤ c₁)] :
  res r V r' c₁ c₃ n ≫ res r V r' c₃ c₅ n = res r V r' c₁ c₅ n :=
CLCFPTinv₂.res_comp_res _ _ _ _ _ _ _ _ _ _

end CLCFPTinv

namespace breen_deligne

open CLCFPTinv

variables (M) {l m n}

-- namespace basic_universal_map

-- variables (ϕ : basic_universal_map m n)

-- def eval_CLCFPTinv [ϕ.suitable c₁ c₂] :
--   CLCFPTinv r V r' M c₂ n ⟶ CLCFPTinv r V r' M c₁ m :=
-- equalizer.map (ϕ.eval_CLCFP _ _ _ _ _) (ϕ.eval_CLCFP _ _ _ _ _)
-- (Tinv_comp_eval_CLCFP _ _ _ _ _ _) $
-- show (CLCFP.T_inv r V r' c₂ n ≫ CLCFP.res V r' (r' * c₂) c₂ n) ≫ (eval_CLCFP V r' M (r' * c₁) (r' * c₂) ϕ) =
--     (eval_CLCFP V r' M c₁ c₂ ϕ) ≫ (CLCFP.T_inv r V r' c₁ m ≫ CLCFP.res V r' (r' * c₁) c₁ m),
-- by rw [category.assoc, res_comp_eval_CLCFP V r' M (r' * c₁) c₁ (r' * c₂) c₂,
--     ← category.assoc, T_inv_comp_eval_CLCFP, category.assoc]

-- lemma map_comp_eval_CLCFPTinv [ϕ.suitable c₁ c₂] :
--   map r V r' c₂ n f ≫ ϕ.eval_CLCFPTinv r V r' M₁ c₁ c₂ =
--     ϕ.eval_CLCFPTinv r V r' M₂ c₁ c₂ ≫ map r V r' c₁ m f :=
-- calc _ = _ : equalizer.map_comp_map _ _ _ _
--    ... = _ : by { congr' 1; apply map_comp_eval_CLCFP }
--    ... = _ : (equalizer.map_comp_map _ _ _ _).symm

-- lemma res_comp_eval_CLCFPTinv
--   [fact (c₁ ≤ c₂)] [ϕ.suitable c₂ c₄] [ϕ.suitable c₁ c₃] [fact (c₃ ≤ c₄)] :
--   res r V r' c₃ c₄ n ≫ ϕ.eval_CLCFPTinv r V r' M c₁ c₃ =
--     ϕ.eval_CLCFPTinv r V r' M c₂ c₄ ≫ res r V r' c₁ c₂ m :=
-- calc _ = _ : equalizer.map_comp_map _ _ _ _
--    ... = _ : by { congr' 1; apply res_comp_eval_CLCFP }
--    ... = _ : (equalizer.map_comp_map _ _ _ _).symm

-- end basic_universal_map

namespace universal_map

variables (ϕ : universal_map m n)

def eval_CLCFPTinv₂
  [fact (c₂ ≤ r' * c₁)] [fact (c₄ ≤ r' * c₃)]
  [ϕ.suitable c₃ c₁] [ϕ.suitable c₄ c₂] :
  CLCFPTinv₂ r V r' c₁ c₂ n ⟶ CLCFPTinv₂ r V r' c₃ c₄ m :=
begin
  dsimp only [CLCFPTinv₂_def],
  refine NormedGroup.equalizer.map_nat (ϕ.eval_CLCFP _ _ _ _) (ϕ.eval_CLCFP _ _ _ _)
    (Tinv_comp_eval_CLCFP V r' c₁ c₂ c₃ c₄ ϕ).symm _,
  have h₁ := T_inv_comp_eval_CLCFP r V r' c₁ c₃ ϕ,
  haveI : fact (c₂ ≤ c₁) := aux r' _ _, haveI : fact (c₄ ≤ c₃) := aux r' _ _,
  have h₂ := res_comp_eval_CLCFP V r' c₁ c₂ c₃ c₄ ϕ,
  exact (comm_sq₂ h₁ h₂).symm,
end

@[simp] lemma eval_CLCFPTinv₂_zero
  [fact (c₂ ≤ r' * c₁)] [fact (c₄ ≤ r' * c₃)] :
  (0 : universal_map m n).eval_CLCFPTinv₂ r V r' c₁ c₂ c₃ c₄ = 0 :=
by { simp only [eval_CLCFPTinv₂, eval_CLCFP_zero, equalizer.map_ι], ext, refl }

lemma eval_CLCFPTinv₂_comp
  [fact (c₂ ≤ r' * c₁)] [fact (c₄ ≤ r' * c₃)] [fact (c₆ ≤ r' * c₅)]
  {l m n : FreeMat} (f : l ⟶ m) (g : m ⟶ n)
  [(f ≫ g).suitable c₅ c₁] [(f ≫ g).suitable c₆ c₂]
  [f.suitable c₅ c₃] [f.suitable c₆ c₄] [g.suitable c₃ c₁] [g.suitable c₄ c₂] :
  (f ≫ g).eval_CLCFPTinv₂ r V r' c₁ c₂ c₅ c₆ =
  g.eval_CLCFPTinv₂ r V r' c₁ c₂ c₃ c₄ ≫ f.eval_CLCFPTinv₂ r V r' c₃ c₄ c₅ c₆ :=
begin
  dsimp only [eval_CLCFPTinv₂, CLCFPTinv₂_def], delta id,
  simp only [NormedGroup.equalizer.map_nat_comp_map_nat,
    ← eval_CLCFP_comp],
  refl,
end

lemma res_comp_eval_CLCFPTinv₂
  [fact (c₁ ≤ c₂)] [ϕ.suitable c₂ c₄] [ϕ.suitable c₁ c₃] [fact (c₃ ≤ c₄)] :
  res r V r' c₃ c₄ n ≫ ϕ.eval_CLCFPTinv₂ r V r' c₁ c₃ =
    ϕ.eval_CLCFPTinv₂ r V r' c₂ c₄ ≫ res r V r' c₁ c₂ m :=
calc _ = _ : equalizer.map_comp_map _ _ _ _
   ... = _ : by { congr' 1; apply res_comp_eval_CLCFP }
   ... = _ : (equalizer.map_comp_map _ _ _ _).symm

def eval_CLCFPTinv [ϕ.suitable c₁ c₂] : CLCFPTinv r V r' c₂ n ⟶ CLCFPTinv r V r' c₁ m :=
eval_CLCFPTinv₂ _ _ _ _ _ _ _ ϕ

@[simp] lemma eval_CLCFPTinv_zero : (0 : universal_map m n).eval_CLCFPTinv r V r' c₁ c₂ = 0 :=
eval_CLCFPTinv₂_zero _ _ _ _ _ _ _

open category_theory.limits

lemma eval_CLCFPTinv_comp {l m n : FreeMat} (g : m ⟶ n) (f : l ⟶ m)
  [hg : g.suitable c₂ c₃] [hf : f.suitable c₁ c₂] [(comp g f).suitable c₁ c₃] :
  (f ≫ g).eval_CLCFPTinv r V r' M c₁ c₃ =
    g.eval_CLCFPTinv r V r' M c₂ c₃ ≫ f.eval_CLCFPTinv r V r' M c₁ c₂ :=
calc _ = _ : by { delta eval_CLCFPTinv, congr' 1; apply eval_CLCFP_comp }
   ... = _ : (equalizer.map_comp_map _ _ _ _).symm

lemma map_comp_eval_CLCFPTinv [ϕ.suitable c₁ c₂] :
  map r V r' c₂ n f ≫ ϕ.eval_CLCFPTinv r V r' M₁ c₁ c₂ =
    ϕ.eval_CLCFPTinv r V r' M₂ c₁ c₂ ≫ map r V r' c₁ m f :=
calc _ = _ : equalizer.map_comp_map _ _ _ _
   ... = _ : by { congr' 1; apply map_comp_eval_CLCFP }
   ... = _ : (equalizer.map_comp_map _ _ _ _).symm

lemma res_comp_eval_CLCFPTinv
  [fact (c₁ ≤ c₂)] [ϕ.suitable c₂ c₄] [ϕ.suitable c₁ c₃] [fact (c₃ ≤ c₄)] :
  res r V r' c₃ c₄ n ≫ ϕ.eval_CLCFPTinv r V r' M c₁ c₃ =
    ϕ.eval_CLCFPTinv r V r' M c₂ c₄ ≫ res r V r' c₁ c₂ m :=
calc _ = _ : equalizer.map_comp_map _ _ _ _
   ... = _ : by { congr' 1; apply res_comp_eval_CLCFP }
   ... = _ : (equalizer.map_comp_map _ _ _ _).symm

end universal_map

end breen_deligne
