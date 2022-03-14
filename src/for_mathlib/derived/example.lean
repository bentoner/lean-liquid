import for_mathlib.derived.K_projective
import for_mathlib.complex_extend
import for_mathlib.projectives

.

universes v u

open category_theory homotopy_category

variables {C : Type u} {ι : Type*} [category.{v} C] [abelian C] {c : complex_shape ι}

open_locale zero_object

instance projective_zero : projective (0 : C) :=
{ factors := λ E X f e he, ⟨0, by ext⟩ }

variables [enough_projectives C]

lemma is_zero_homology_of_exact {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) (hfg : exact f g) :
  is_zero (homology f g hfg.w) :=
begin
  rw projective.preadditive.exact_iff_homology_is_zero at hfg,
  obtain ⟨w, H⟩ := hfg,
  exact H,
end

lemma category_theory.is_zero.is_iso {X Y : C} (hX : is_zero X) (hY : is_zero Y) (f : X ⟶ Y) :
  is_iso f :=
{ out := ⟨0, hX.eq_of_src _ _, hY.eq_of_tgt _ _⟩ }

lemma category_theory.is_iso_of_nat_iso {C D : Type*} [category C] [category D]
  {F G : C ⥤ D} (α : F ≅ G)
  {X Y : C} (f : X ⟶ Y) (h : is_iso (F.map f)) :
  is_iso (G.map f) :=
begin
  rw ← nat_iso.naturality_1 α f,
  apply_instance,
end

lemma category_theory.nat_iso.is_iso_iff {C D : Type*} [category C] [category D]
  {F G : C ⥤ D} (α : F ≅ G)
  {X Y : C} (f : X ⟶ Y) :
  is_iso (F.map f) ↔ is_iso (G.map f) :=
⟨category_theory.is_iso_of_nat_iso α _, category_theory.is_iso_of_nat_iso α.symm _⟩

open category_theory

@[simps obj obj_val map]
noncomputable def chain_complex.to_bounded_homotopy_category :
  chain_complex C ℕ ⥤ bounded_homotopy_category C :=
{ obj := λ P,
  { val := (homological_complex.embed (complex_shape.embedding.nat_down_int_up) ⋙
      homotopy_category.quotient C _).obj P,
    bdd := begin
      refine ⟨⟨1, _⟩⟩,
      rintro ((_|i)|i) h,
      { exfalso, revert h, dec_trivial },
      { exact is_zero_zero _ },
      { exfalso, revert h, dec_trivial }
    end },
  map := λ P Q f, (homological_complex.embed (complex_shape.embedding.nat_down_int_up) ⋙
      homotopy_category.quotient C _).map f,
  map_id' := λ P, (homological_complex.embed (complex_shape.embedding.nat_down_int_up) ⋙
      homotopy_category.quotient C _).map_id P,
  map_comp' := λ P Q R f g, (homological_complex.embed (complex_shape.embedding.nat_down_int_up) ⋙
      homotopy_category.quotient C _).map_comp f g }

lemma chain_complex.to_bounded_homotopy_category.is_K_projective (P : chain_complex C ℕ)
  (A : C) (π : P ⟶ (chain_complex.single₀ C).obj A)
  (hP : P.is_projective_resolution A π) :
  is_K_projective (chain_complex.to_bounded_homotopy_category.obj P).val :=
begin
  constructor,
  introsI Y hY f,
  rw [← quotient_map_out f],
  apply eq_of_homotopy,
  refine projective.null_homotopic_of_projective_to_acyclic _ 1 _ _ hY.cond,
  { rintro ((_|i)|i),
    { exact hP.projective 0 },
    { exact projective_zero, },
    { exact hP.projective _ }, },
  { rintro ((_|i)|i),
    { intro h, exfalso, revert h, dec_trivial },
    { intro h, exact is_zero_zero _ },
    { intro h, exfalso, revert h, dec_trivial } },
end
.

lemma chain_complex.is_projective_resolution.is_quasi_iso_embed {P : chain_complex C ℕ}
  {A : C} {π : P ⟶ (chain_complex.single₀ C).obj A}
  (hP : P.is_projective_resolution A π) :
  is_quasi_iso ((homological_complex.embed (complex_shape.embedding.nat_down_int_up) ⋙
       homotopy_category.quotient C _).map π) :=
begin
  constructor,
  intro i,
  rw [← functor.comp_map, category_theory.nat_iso.is_iso_iff
    (functor.associator _ _ _ ≪≫ iso_whisker_left _ (homology_factors _ _ _))],
  rcases i with ((_|i)|i),
  { -- use chain_complex.homology_functor_0_single₀,
    sorry },
  { refine is_zero.is_iso _ _ _; refine is_zero_homology_of_exact _ _ _, },
  { refine is_zero.is_iso _ _ _,
    { refine is_zero_of_iso_of_zero _ (homology_iso _ (-[1+i.succ] : ℤ) _ (-i : ℤ) _ _).symm,
      rotate,
      { dsimp, refl, },
      { dsimp, simp only [int.neg_succ_of_nat_eq', sub_add_cancel], },
      refine is_zero_homology_of_exact _ _ _,
      cases i; exact (hP.exact _), },
    { refine is_zero_of_iso_of_zero _ (homology_iso _ (-[1+i.succ] : ℤ) _ (-i : ℤ) _ _).symm,
      rotate,
      { dsimp, refl, },
      { dsimp, simp only [int.neg_succ_of_nat_eq', sub_add_cancel], },
      refine is_zero_homology_of_exact _ _ _, } }
end
.

open opposite

namespace homological_complex

@[simps]
def op (X : homological_complex C c) : homological_complex Cᵒᵖ c.symm :=
{ X := λ i, op (X.X i),
  d := λ i j, (X.d j i).op,
  shape' := λ i j hij, by { rw [X.shape j i hij, op_zero], },
  d_comp_d' := by { intros, rw [← op_comp, X.d_comp_d, op_zero], } }

@[simps]
def unop (X : homological_complex Cᵒᵖ c) : homological_complex C c.symm :=
{ X := λ i, unop (X.X i),
  d := λ i j, (X.d j i).unop,
  shape' := λ i j hij, by { rw [X.shape j i hij, unop_zero], },
  d_comp_d' := by { intros, rw [← unop_comp, X.d_comp_d, unop_zero], } }

end homological_complex

@[to_additive]
lemma subgroup.comap_eq_iff {A B : Type*} [comm_group A] [comm_group B] (f : A ≃* B)
  (C : subgroup A) (D : subgroup B) :
  D.comap f.to_monoid_hom = C ↔ C.comap f.symm.to_monoid_hom = D :=
begin
  split; rintro rfl; ext,
  { simp only [subgroup.mem_comap, mul_equiv.coe_to_monoid_hom, mul_equiv.apply_symm_apply], },
  { simp only [subgroup.mem_comap, mul_equiv.coe_to_monoid_hom, mul_equiv.symm_apply_apply], }
end

@[to_additive] noncomputable
def mul_equiv.surjective_congr {A B C D : Type*}
  [comm_group A] [comm_group B] [comm_group C] [comm_group D]
  (e : A ≃* B) (f : A →* C) (g : B →* D)
  (hf : function.surjective f) (hg : function.surjective g)
  (he : g.ker.comap e.to_monoid_hom = f.ker) :
C ≃* D :=
{ to_fun := f.lift_of_surjective hf ⟨g.comp e.to_monoid_hom, λ x hx,
  by { rw ← he at hx, exact hx }⟩,
  inv_fun := g.lift_of_surjective hg ⟨f.comp e.symm.to_monoid_hom, λ x hx,
  by { rw subgroup.comap_eq_iff at he, rw ← he at hx, exact hx, }⟩,
  left_inv := λ x, begin
    obtain ⟨x, rfl⟩ := hf x,
    delta monoid_hom.lift_of_surjective,
    simp only [monoid_hom.lift_of_right_inverse_comp_apply, subtype.coe_mk, monoid_hom.comp_apply],
    convert monoid_hom.lift_of_right_inverse_comp_apply _ _ _ _ (e.to_monoid_hom x) using 1,
    exact f.congr_arg (e.symm_apply_apply x).symm,
  end,
  right_inv := λ x, begin
    obtain ⟨x, rfl⟩ := hg x,
    delta monoid_hom.lift_of_surjective,
    simp only [monoid_hom.lift_of_right_inverse_comp_apply, subtype.coe_mk, monoid_hom.comp_apply],
    convert monoid_hom.lift_of_right_inverse_comp_apply _ _ _ _ (e.symm.to_monoid_hom x) using 1,
    exact g.congr_arg (e.apply_symm_apply x).symm,
  end,
  map_mul' := λ x y, monoid_hom.map_mul _ _ _ }

@[to_additive]
def mul_equiv.quotient_congr {A B : Type*} [comm_group A] [comm_group B] (f : A ≃* B)
  (C : subgroup A) (D : subgroup B) (h : D.comap f.to_monoid_hom = C) :
A ⧸ C ≃* B ⧸ D :=
{ to_fun := quotient_group.map _ _ f.to_monoid_hom h.ge,
  inv_fun := quotient_group.map _ _ f.symm.to_monoid_hom
  begin
    refine le_of_eq _, subst h, ext,
    simp only [subgroup.mem_comap, mul_equiv.coe_to_monoid_hom, mul_equiv.apply_symm_apply],
  end,
  left_inv := λ x, begin
    induction x using quotient_group.induction_on,
    erw [quotient_group.map_coe, f.symm_apply_apply],
    refl,
  end,
  right_inv := λ x, begin
    induction x using quotient_group.induction_on,
    erw [quotient_group.map_coe, f.apply_symm_apply],
    refl,
  end,
  map_mul' := λ x y, monoid_hom.map_mul _ _ _ }
.

attribute [elementwise] limits.kernel.lift_ι iso.hom_inv_id

noncomputable
def AddCommGroup.homology_iso {A B C : AddCommGroup.{u}} (f : A ⟶ B) (g : B ⟶ C) (w : f ≫ g = 0) :
  homology f g w ≅ AddCommGroup.of (g.ker ⧸ (f.range.comap g.ker.subtype)) :=
begin
  refine homology_iso_cokernel_lift f g w ≪≫
    AddCommGroup.cokernel_iso_quotient _ ≪≫
    add_equiv_iso_AddCommGroup_iso.hom _,
  refine add_equiv.quotient_congr _ _ _ _,
  { exact add_equiv_iso_AddCommGroup_iso.inv (AddCommGroup.kernel_iso_ker _) },
  rw add_subgroup.comap_eq_iff,
  show add_subgroup.comap (AddCommGroup.kernel_iso_ker g).inv
    (add_monoid_hom.range (limits.kernel.lift g f w)) =
    add_subgroup.comap (add_monoid_hom.ker g).subtype (add_monoid_hom.range f),
  dsimp only [AddCommGroup.kernel_iso_ker],
  have : function.injective (λ x, limits.kernel.ι g x),
  { rw [← AddCommGroup.kernel_iso_ker_hom_comp_subtype, coe_comp],
    have : function.injective (g.ker.subtype) := subtype.val_injective,
    refine this.comp _,
    refine function.has_left_inverse.injective _,
    refine ⟨(AddCommGroup.kernel_iso_ker _).inv, _⟩,
    intro y, refine category_theory.iso.hom_inv_id_apply (AddCommGroup.kernel_iso_ker g) y, },
  ext ⟨x, hx⟩,
  simp only [add_subgroup.mem_comap, add_monoid_hom.mem_range, add_subgroup.coe_subtype,
    subtype.coe_mk, ← this.eq_iff, category_theory.limits.kernel.lift_ι_apply],
end
.

def homotopy_category.quotient_map_hom (A B : homological_complex C c) :
  (A ⟶ B) →+ ((homotopy_category.quotient C c).obj A ⟶ (homotopy_category.quotient C c).obj B) :=
add_monoid_hom.mk' (λ f, (homotopy_category.quotient C c).map f) $ λ f g, rfl

lemma quot.mk_surjective {X : Type*} (r : X → X → Prop) :
  function.surjective (quot.mk r) :=
λ x, quot.induction_on x $ λ x, ⟨x, rfl⟩

open category_theory.limits

noncomputable
def bounded_homotopy_category.hom_shift_single_iso
  (P : bounded_homotopy_category C) (B : C) (i : ℤ) :
  AddCommGroup.of (P ⟶ (shift_functor (bounded_homotopy_category C) i).obj
    ((bounded_homotopy_category.single 0).obj B)) ≅
  (((preadditive_yoneda.obj B).map_homological_complex _).obj P.val.as.op).homology (-i) :=
begin
  refine _ ≪≫ (homology_iso _ (-i+1) (-i) (-i-1) _ _).symm,
  rotate, { dsimp, refl }, { dsimp, exact sub_add_cancel _ _ },
  refine add_equiv_iso_AddCommGroup_iso.hom _ ≪≫ (AddCommGroup.homology_iso _ _ _).symm,
  refine add_equiv.surjective_congr _
    (homotopy_category.quotient_map_hom _ _)
    (quotient_add_group.mk' _) (quot.mk_surjective _) (quot.mk_surjective _) _,
  refine
  { to_fun := begin
      intro f,
      refine ⟨_, _⟩,
      { refine f.f (-i) ≫ _,
        dsimp [bounded_homotopy_category.shift_functor_obj_val, bounded_homotopy_category.single],
        simp only [add_left_neg, eq_self_iff_true, if_true],
        exact 𝟙 B, },
      { simp only [add_left_neg, eq_self_iff_true, ite_eq_left_iff, not_true, forall_false_left,
          congr_arg_mpr_hom_left, category.comp_id, id.def, functor.map_homological_complex_obj_d,
          homological_complex.op_d, add_monoid_hom.mem_ker],
        erw [preadditive_yoneda_obj_map_apply, quiver.hom.unop_op, ← category.assoc,
          ← homological_complex.hom.comm],
        dsimp [bounded_homotopy_category.single],
        simp only [smul_zero, comp_zero, zero_comp], }
    end,
    inv_fun := begin
      intro f, sorry,
      -- refine { f := λ j, _, comm' := _ },
      -- { dsimp [bounded_homotopy_category.shift_functor_obj_val, bounded_homotopy_category.single],
      --   generalize hl : j + i = l,
      --   rcases l with ((_|l)|l),
      --   { cases f with f hf,
      --     erw add_eq_zero_iff_eq_neg at hl, subst j,
      --     exact f, },
      --   { exact 0 },
      --   { exact 0 } },
      -- { intros j k hjk, dsimp at hjk, subst k,
      --   generalize hl : j + i = l, dsimp,
      --   split_ifs with h, swap, { dsimp, } }
    end,
    left_inv := _,
    right_inv := _,
    map_add' := _ },
  all_goals { sorry },
end

noncomputable
def Ext'_iso (A : Cᵒᵖ) (B : C) (i : ℤ) (P : chain_complex C ℕ)
  (π : P ⟶ (chain_complex.single₀ C).obj A.unop)
  (hP : P.is_projective_resolution A.unop π) :
  ((Ext' i).obj A).obj B ≅
  (((preadditive_yoneda.obj B).map_homological_complex _).obj
    ((homological_complex.embed complex_shape.embedding.nat_down_int_up).obj P).op).homology (-i) :=
begin
  dsimp only [Ext', functor.comp_obj, functor.op_obj, functor.flip_obj_obj],
  haveI := chain_complex.to_bounded_homotopy_category.is_K_projective P A.unop π hP,
  haveI : is_quasi_iso (chain_complex.to_bounded_homotopy_category.map π) := hP.is_quasi_iso_embed,
  refine (bounded_homotopy_category.Ext_iso i
    (chain_complex.to_bounded_homotopy_category.obj P)
    _ _ (chain_complex.to_bounded_homotopy_category.map π ≫ _)) ≪≫
    bounded_homotopy_category.hom_shift_single_iso _ B i,
  { exact ((homotopy_category.quotient _ _).map_iso $
      (chain_complex.single₀_comp_embed_iso_single).app A.unop).hom, },
  { apply_instance },
end

lemma AddCommGroup.is_zero_of_eq (A : AddCommGroup) (h : ∀ x y : A, x = y) :
  is_zero A :=
{ eq_zero_of_src := λ B f, by { ext, cases h x 0, exact f.map_zero },
  eq_zero_of_tgt := λ B f, by { ext, exact h _ _ } }

lemma Ext_is_zero_of_neg (A : Cᵒᵖ) (B : C) (i : ℤ) (hi : i < 0) :
  is_zero (((Ext' i).obj A).obj B) :=
begin
  dsimp [Ext'],
  sorry
  -- refine is_zero_of_iso_of_zero _ (bounded_homotopy_category.Ext_iso _ _ _ _ _).symm,

  -- refine AddCommGroup.is_zero_of_eq _ _,
  -- dsimp [Ext', bounded_homotopy_category.Ext],
  -- intros f g,
  -- apply bounded_homotopy_category.hom_ext,
  -- apply homotopy_category.eq_of_homotopy,
  -- sorry
end