from django.db import models

class QuestionSet(models.Model):
    LEVEL_CHOICES = [('N5','N5'),('N4','N4'),('JFT','JFT Basic'),
                     ('vocab','Vocabulary'),('grammar','Grammar'),
                     ('reading','Reading'),('listening','Listening')]
    title              = models.CharField(max_length=200)
    title_ja           = models.CharField(max_length=200, blank=True)
    category           = models.CharField(max_length=20, choices=LEVEL_CHOICES)
    level              = models.CharField(max_length=20, default='N5')
    duration_minutes   = models.IntegerField(default=60)
    passing_percentage = models.FloatField(default=65.0)
    is_active          = models.BooleanField(default=True)
    order              = models.IntegerField(default=0)
    created_at         = models.DateTimeField(auto_now_add=True)

    class Meta: ordering = ['order', 'created_at']
    def __str__(self): return self.title

    @property
    def question_count(self): return self.questions.count()
    @property
    def total_marks(self):    return self.questions.count()

class Question(models.Model):
    DIFFICULTY_CHOICES = [('easy','Easy'),('medium','Medium'),('hard','Hard')]
    question_set         = models.ForeignKey(QuestionSet, related_name='questions', on_delete=models.CASCADE)
    question_text        = models.TextField()
    question_text_ja     = models.TextField(blank=True, null=True)
    options              = models.JSONField()          # list of 4 strings
    correct_option_index = models.IntegerField()
    explanation          = models.TextField(blank=True, null=True)
    explanation_ja       = models.TextField(blank=True, null=True)
    category             = models.CharField(max_length=50, default='General')
    difficulty           = models.CharField(max_length=10, choices=DIFFICULTY_CHOICES, default='medium')
    audio_url            = models.URLField(blank=True, null=True)
    image_url            = models.URLField(blank=True, null=True)
    order                = models.IntegerField(default=0)

    class Meta: ordering = ['order']
    def __str__(self): return self.question_text[:60]